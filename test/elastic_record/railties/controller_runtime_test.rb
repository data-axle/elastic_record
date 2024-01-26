require 'helper'
require "elastic_record/railties/controller_runtime"

class ElasticRecord::Railties::ControllerRuntimeTest < Minitest::Test
  class TestRuntime
    def self.log_process_action(payload)
      ['sweet']
    end

    def cleanup_view_runtime
      12
    end

    def append_info_to_payload(payload)
      payload[:foo] = 42
    end

  end

  class ElasticRuntime < TestRuntime
    include ElasticRecord::Railties::ControllerRuntime
  end

  def test_cleanup_view_runtime
    runtime = ElasticRuntime.new
    ElasticRecord::LogSubscriber.runtime = 10

    runtime.cleanup_view_runtime

    assert_equal 0, ElasticRecord::LogSubscriber.runtime
  end

  def test_append_info_to_payload
    runtime = ElasticRuntime.new
    payload = {}
    runtime.append_info_to_payload(payload)

    assert_equal 42, payload[:foo]
    assert payload.key?(:elastic_record_runtime)
  end

  def test_log_process_action
    payload = {elastic_record_runtime: 12.3}
    messages = ElasticRuntime.log_process_action(payload)

    assert_equal 2, messages.size
    assert_equal "ElasticRecord: 12.3ms", messages.last
  end
end
