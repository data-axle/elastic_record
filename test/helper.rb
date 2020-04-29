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

      ElasticRecord::ConnectionHandler.enable_deferring!
    end

    def teardown
      ElasticRecord::ConnectionHandler.reset_deferring!
      ElasticRecord::ConnectionHandler.real_connection.json_post("/_all/_delete_by_query", query: {match_all: {}})
    end
  end
end
