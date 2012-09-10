module ElasticRecord
  class Connection
    # :timeout: 10
    # :retries: 2
    # :auto_discovery: false

    attr_accessor :servers, :options
    def initialize(servers, options = {})
      if servers.is_a?(Array)
        self.servers = servers
      else
        self.servers = servers.split(',')
      end

      self.options = options
    end

    def head(path)
      http_request(Net::HTTP::Head, path).code
    end

    def json_get(path, json = nil)
      json_request Net::HTTP::Get, path, json
    end

    def json_post(path, json = nil)
      json_request Net::HTTP::Post, path, json
    end

    def json_put(path, json = nil)
      json_request Net::HTTP::Put, path, json
    end

    def json_delete(path, json = nil)
      json_request Net::HTTP::Delete, path, json
    end

    private
      def current_server
        servers.first
      end

      def json_request(request_klass, path, json)
        body = json ? ActiveSupport::JSON.encode(json) : nil
        response = http_request(request_klass, path, body)
        json = ActiveSupport::JSON.decode response.body

        raise json['error'] if json['error']

        json
      end

      def http_request(request_klass, path, body = nil)
        request = request_klass.new(path)
        request.body = body

        http.request(request)
      end

      def connection
        @model.elastic_connection
      end

      def http
        host, port = current_server.split ':'
        Net::HTTP.new(host, port)
      end
  end
end