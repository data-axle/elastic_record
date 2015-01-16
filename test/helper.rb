ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)

require 'minitest/autorun'

FakeWeb.allow_net_connect = %r[^https?://127.0.0.1]

module MiniTest
  class Test
    def setup
      FakeWeb.clean_registry

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
