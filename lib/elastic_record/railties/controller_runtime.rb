require 'active_support/core_ext/module/attr_internal'
require 'elastic_record/log_subscriber'

module ElasticRecord
  module Railties # :nodoc:
    module ControllerRuntime #:nodoc:
      extend ActiveSupport::Concern

    protected

      attr_internal :elastic_record_runtime

      def process_action(action, *args)
        # We also need to reset the runtime before each action
        # because of queries in middleware or in cases we are streaming
        # and it won't be cleaned up by the method below.
        ElasticRecord::LogSubscriber.reset_runtime
        super
      end

      def cleanup_view_runtime
        runtime_before_render = ElasticRecord::LogSubscriber.reset_runtime
        runtime = super
        runtime_after_render = ElasticRecord::LogSubscriber.reset_runtime
        self.elastic_record_runtime = runtime_before_render + runtime_after_render
        runtime - runtime_after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:elastic_record_runtime] = (elastic_record_runtime || 0) + ElasticRecord::LogSubscriber.reset_runtime
      end

      module ClassMethods # :nodoc:
        def log_process_action(payload)
          messages, elastic_record_runtime = super, payload[:elastic_record_runtime]
          if elastic_record_runtime.to_i > 0
            messages << ("ElasticRecord: %.1fms" % elastic_record_runtime.to_f) 
          end
          messages
        end
      end
    end
  end
end
