module ElasticRecord
  class ConnectionHandler
    class << self
      def connection
        @deferring_enabled ? deferred_connection : real_connection
      end

      def disable_deferring!
        @deferring_enabled = false
      end

      def deferred_connection
        @deferred_connection ||= ElasticRecord::DeferredConnection.new
      end

      def enable_deferring!
        @deferring_enabled = true
      end

      def real_connection
        @real_connection ||= ElasticRecord::Connection.new(ElasticRecord::Config.servers, ElasticRecord::Config.connection_options)
      end

      def reset_deferring!
        deferred_connection.reset!
      end
    end
  end
end
