require 'helper'
require "elastic_record/railties/controller_runtime"

class ElasticRecord::Railties::ControllerRuntimeTest < MiniTest::Spec
  class TestRuntime
    def self.log_process_action(payload)
      ['sweet']
    end

    def cleanup_view_runtime
      yield
    end

    def append_info_to_payload(payload)
      payload[:foo] = 42
    end
  end

  TestRuntime.include ElasticRecord::Railties::ControllerRuntime

  def test_stuff
    
  end
end
