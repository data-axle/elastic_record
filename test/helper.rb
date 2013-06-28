require 'bundler/setup'
Bundler.require

require 'minitest/autorun'

require 'support/connect'
require 'support/query_counter'
require 'support/models/test_model'
require 'support/models/warehouse'
require 'support/models/widget'
require 'support/models/option'
require 'pp'

ElasticRecord::Config.model_names = %w(Warehouse Widget Option)

FakeWeb.allow_net_connect = %r[^https?://127.0.0.1]

module MiniTest
  class Unit
    class TestCase
      def setup
        Widget._test_cache.clear
        Option._test_cache.clear

        FakeWeb.clean_registry

        Widget.elastic_index.create_and_deploy if Widget.elastic_index.all_names.empty?

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
end
