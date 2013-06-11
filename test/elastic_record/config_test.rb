require 'helper'

class ElasticRecord::ConfigTest < MiniTest::Spec
  def test_defaults
    assert_equal '5m', ElasticRecord::Config.scroll_keep_alive
  end

  def test_models
    ElasticRecord::Config.model_names = %w(Widget)

    assert_equal [Warehouse, Widget, Option], ElasticRecord::Config.models
  end
end
