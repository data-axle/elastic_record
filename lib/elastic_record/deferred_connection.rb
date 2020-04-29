module ElasticRecord
  class DeferredConnection
    class DeferredAction < Struct.new(:method, :args, :block)
      def run
        ConnectionHandler.real_connection.send(method, *args, &block)
      end
    end

    attr_accessor :deferred_actions
    attr_accessor :writes_made

    def initialize
      reset!
    end

    def reset!
      if writes_made
        begin
          ConnectionHandler.disable_deferring!
          refresh_indices
        ensure
          ConnectionHandler.enable_deferring!
        end
      end

      self.deferred_actions = []
      self.writes_made = false
    end

    private
      READ_METHODS = [:json_get, :head]

      def method_missing(method, *args, &block)
        super unless ConnectionHandler.real_connection.respond_to?(method)

        if READ_METHODS.include?(method)
          flush_deferred_actions!

          refresh_indices if method == :json_get && args.first =~ /^\/(.*)\/_m?search/

          ConnectionHandler.real_connection.send(method, *args, &block)
        else
          deferred_actions << DeferredAction.new(method, args, block)
        end
      end

      def flush_deferred_actions!
        deferred_actions.each do |queued_action|
          self.writes_made = true

          queued_action.run
        end

        deferred_actions.clear
      end

      def refresh_indices
        ConnectionHandler.real_connection.json_post("/_refresh")
      end
  end
end
