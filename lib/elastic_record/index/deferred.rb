module ElasticRecord
  class Index
    module Deferred
      class DeferredConnection

        attr_accessor :index
        attr_accessor :writes_made
        attr_accessor :bulk_stack

        def initialize(index)
          @index = index
          @bulk_stack = []
          reset!
        end

        def reset!
          if writes_made
            index.delete_by_query query: {match_all: {}}
            self.writes_made = false
          end
        end

        private
          READ_METHODS = [:json_get, :head]
          def method_missing(method, *args, &block)
            super unless index.real_connection.respond_to?(method)

            if READ_METHODS.exclude?(method)
              self.writes_made = true
            end

            index.real_connection.send(method, *args, &block)
          end
      end

      def enable_deferring!
        @deferring_enabled = true
      end

      def disable_deferring!
        @deferring_enabled = false
      end

      def connection
        if @deferring_enabled
          deferred_connection
        else
          real_connection
        end
      end

      def reset_deferring!
        deferred_connection.reset!
      end

      def deferred_connection
        @deferred_connection ||= DeferredConnection.new(self)
      end
    end
  end
end
