ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)

require 'minitest/autorun'
require 'webmock/minitest'

module MiniTest
  class Test
    def setup
      WebMock.reset!
      WebMock.disable_net_connect!(allow_localhost: true)

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
