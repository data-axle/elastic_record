require 'helper'

class ElasticRecord::ConfigTest < MiniTest::Spec
  def test_models
    ElasticRecord::Config.model_names = %w(Widget)

    assert_equal [Warehouse, Widget], ElasticRecord::Config.models
  end
end