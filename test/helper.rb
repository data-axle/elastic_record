require 'bundler/setup'
Bundler.require

require 'minitest/autorun'

require 'support/connect'
require 'support/models/test_model'
require 'support/models/warehouse'
require 'support/models/widget'
Widget.elastic_index.reset

ElasticRecord::Config.model_names = %w(Warehouse Widget)

FakeWeb.allow_net_connect = %r[^https?://127.0.0.1]

module MiniTest
  class Spec
    def setup
      super
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
