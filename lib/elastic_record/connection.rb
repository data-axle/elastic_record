require 'net/http'

module ElasticRecord
  class Connection
    attr_accessor :servers, :options
    attr_accessor :request_count, :current_server
    attr_accessor :max_request_count

    def initialize(servers, options = {})
      self.servers = Array(servers)

      @shuffled_servers       = nil
      self.current_server     = next_server
      self.request_count      = 0
      self.max_request_count  = 100
      self.options            = options.symbolize_keys
    end

    def head(path)
      http_request_with_retry(:head, path).code
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
      body = json.is_a?(Hash) ? JSON.generate(json) : json
      response = http_request_with_retry(method, path, body)

      json = JSON.parse(response.body)
      raise ConnectionError.new(response.code, json['error']) if json['error']

      json
    end

    def http_request_with_retry(*args)
      with_retry do
        response = http_request(*args)

        raise ConnectionError.new(response.code, response.body) if response.code.to_i >= 500

        response
      end
    end

    def http_request(method, path, body = nil)
      request = new_request(method, path, body)
      http = new_http

      ActiveSupport::Notifications.instrument("request.elastic_record") do |payload|
        payload[:http]      = http
        payload[:request]   = request
        payload[:response]  = http.request(request)
      end
    end

    METHODS = {
      head:   Net::HTTP::Head,
      get:    Net::HTTP::Get,
      post:   Net::HTTP::Post,
      put:    Net::HTTP::Put,
      delete: Net::HTTP::Delete
    }
    def new_request(method, path, body)
      request = METHODS[method].new(path.starts_with?('/') ? path : "/#{path}")
      request.basic_auth(options[:username], options[:password]) if options[:username].present?
      request.body = body
      request.content_type = 'application/json'
      request
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

        server = current_server.start_with?('http') ? current_server : "http://#{current_server}"
        uri = URI(server)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        if options[:timeout]
          http.read_timeout = options[:timeout].to_i
        end
        http
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
