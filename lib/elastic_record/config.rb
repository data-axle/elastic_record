module ElasticRecord
  class Config
    class << self
      def servers=(value)
        @servers = value
      end

      def servers
        @servers
      end

      def connection_options
        @connection_options ||= {}
      end

      def connection_options=(options)
        @connection_options = options
      end
    end
  end
end
