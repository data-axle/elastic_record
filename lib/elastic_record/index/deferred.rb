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

        def initialize(index)
          self.index = index
          reset!
        end

        def reset!
          if writes_made
            begin
              index.real_connection.json_delete "/#{index.alias_name}"
              index.real_connection.json_put "/#{index.alias_name}"
              index.real_connection.json_put "/#{index.alias_name}/#{index.type}/_mapping", index.type => index.mapping
            rescue
            end
          end
          self.deferred_actions = []
          self.writes_made = false
        end

        def flush!
          deferred_actions.each do |queued_action|
            self.writes_made = true
            debug "#{queued_action.method} (dequeuing)"
            queued_action.run(index.real_connection)
          end
          deferred_actions.clear
        end

        private
          READ_METHODS = [:json_get, :head]
          def method_missing(method, *args, &block)
            super unless index.real_connection.respond_to?(method)

            if READ_METHODS.include?(method)
              debug "(flushing queue) #{method} #{args}"
              flush!
              index.real_connection.json_post "/#{index.alias_name}/_refresh"
              index.real_connection.send(method, *args, &block)
            else
              debug "(queuing) #{method} #{args}"
              deferred_actions << DeferredAction.new(method, args, block)
            end
          end

          def debug(message)
            # p message
          end
      end

      def enable_deferring!
        @deferring_enabled = true
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