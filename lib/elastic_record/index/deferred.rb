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
        attr_accessor :bulk_actions

        def initialize(index)
          @index = index
          @bulk_actions = nil
          reset!
        end

        def reset!
          if writes_made
            begin
              index.disable_deferring!
              index.refresh
              index.delete_by_query query: {match_all: {}}
            ensure
              index.enable_deferring!
            end
          end
          self.deferred_actions = []
          self.writes_made = false
        end

        private
          def method_missing(method, *args, &block)
            super unless index.real_connection.respond_to?(method)

            if flush_deferred_actions?(method, args)
              flush_deferred_actions!
              if index_name = index_name_from_uri_path(method, args)
                index.real_connection.json_post("/#{index_name}/_refresh")
              end

              index.real_connection.send(method, *args, &block)
            else
              deferred_actions << DeferredAction.new(method, args, block)
            end
          end

          def flush_deferred_actions!
            deferred_actions.each do |queued_action|
              self.writes_made = true
              queued_action.run(index.real_connection)
            end
            deferred_actions.clear
          end

          def index_name_from_uri_path(http_method, args)
            regex =
              case http_method
              when :json_get
                 /^\/(.*)\/_m?search/
              when :json_post
                 /^\/(.*)\/_pit/
              end
            $1.partition('/').first if regex && args.first =~ regex
          end

          READ_METHODS = [:json_get, :head]
          def flush_deferred_actions?(method, args)
            READ_METHODS.include?(method) || flush_deferred_actions_for_json_post?(method, args.first)
          end

          POST_PATHS_THAT_REQUIRE_FLUSH = [
            /^\/_search\/scroll/,
            /^(.*)\/_pit/
          ].freeze
          def flush_deferred_actions_for_json_post?(method, arg)
            method == :json_post && POST_PATHS_THAT_REQUIRE_FLUSH.any? { |path| arg =~ path }
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
