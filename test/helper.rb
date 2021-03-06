ENV["RAILS_ENV"] = "test"

require 'dummy/config/environment'
require 'rails/test_help'
Bundler.require(Rails.env)

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

def MiniTest.filter_backtrace(bt)
  bt
end

module MiniTest
  class Test
    def setup
      WebMock.reset!

      ElasticRecord::Config.models.each do |model|
        model.elastic_index.enable_deferring!
      end
    end

    def teardown
      ElasticRecord::Config.models.each do |model|
        model.elastic_index.reset_deferring!
      end
    end
  end
end
