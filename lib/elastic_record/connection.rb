require 'net/http'

module ElasticRecord
  class Connection
    attr_accessor :servers, :options
    attr_accessor :request_count, :current_server
    attr_accessor :max_request_count
    attr_accessor :bulk_stack
    def initialize(servers, options = {})
      self.servers = Array(servers)

      self.current_server     = next_server
      self.request_count      = 0
      self.max_request_count  = 100
      self.options            = options
      self.bulk_stack        = []
    end

    def head(path)
      http_request(:head, path).code
    end

    def json_get(path, json = nil)
      json_request :get, path, json
    end

    def json_post(path, json = nil)
      json_request :post, path, json
    end

    def json_put(path, json = nil)
      json_request :put, path, json
    end

    def json_delete(path, json = nil)
      json_request :delete, path, json
    end

    def json_request(method, path, json)
      body = json.is_a?(Hash) ? ActiveSupport::JSON.encode(json) : json
      response = http_request(method, path, body)

      json = ActiveSupport::JSON.decode response.body
      raise ConnectionError.new(json['error']) if json['error']

      json
    end

    METHODS = {
      head:   Net::HTTP::Head,
      get:    Net::HTTP::Get,
      post:   Net::HTTP::Post,
      put:    Net::HTTP::Put,
      delete: Net::HTTP::Delete
    }

    def http_request(method, path, body = nil)
      with_retry do
        request = METHODS[method].new(path)
        request.body = body
        http, uri = new_http
        if uri.user || uri.password
          request.basic_auth uri.user, uri.password
        end

        ActiveSupport::Notifications.instrument("request.elastic_record") do |payload|
          payload[:http]      = http
          payload[:request]   = request
          payload[:response]  = http.request(request)
        end
      end
    end

    private
      def next_server
        if @shuffled_servers.nil?
          @shuffled_servers = servers.shuffle
        else
          @shuffled_servers.rotate!
        end

        @shuffled_servers.first
      end

      def new_http
        self.request_count += 1

        if request_count > max_request_count
          self.current_server = next_server
          self.request_count = 0
        end

        uri = URI(current_server.start_with?('http') ? current_server : "http://#{current_server}")
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ENV['ELASTIC_RECORD_SSL_VERIFY_NONE'] == '1'
        end
        if options[:timeout]
          http.read_timeout = options[:timeout].to_i
        end

        [http, uri]
      end

      def with_retry
        retry_count = 0
        begin
          yield
        rescue StandardError
          if retry_count < options[:retries].to_i
            self.current_server = next_server
            retry_count += 1
            retry
          else
            raise
          end
        end
      end
  end
end
