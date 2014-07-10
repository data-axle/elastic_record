module ElasticRecord
  class Index
    module Deferred
      class DeferredConnection
        class DeferredAction < Struct.new(:method, :args, :block)
          def run(index)
            index.send(method, *args, &block)
          end
        end

        attr_accessor :index
        attr_accessor :deferred_actions
        attr_accessor :writes_made
        attr_accessor :bulk_stack

        def initialize(index)
          self.index = index
          self.bulk_stack = []
          reset!
        end

        def reset!
          if writes_made
            begin
              index.disable_deferring!
              index.delete_by_query query: {match_all: {}}
            ensure
              index.enable_deferring!
            end
          end
          self.deferred_actions = []
          self.writes_made = false
        end

        def flush!
          deferred_actions.each do |queued_action|
            self.writes_made = true
            queued_action.run(index.real_connection)
          end
          deferred_actions.clear
        end

        private
          READ_METHODS = [:json_get, :head]
          def method_missing(method, *args, &block)
            super unless index.real_connection.respond_to?(method)

            if READ_METHODS.include?(method)
              flush!
              index.real_connection.json_post("/#{index.alias_name}/_refresh") if requires_refresh?(method, *args)
              index.real_connection.send(method, *args, &block)
            else
              deferred_actions << DeferredAction.new(method, args, block)
            end
          end

          def requires_refresh?(method, *args)
            method == :json_get && args.first =~ /_search/
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
