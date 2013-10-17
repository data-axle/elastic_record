require 'helper'

class ElasticRecord::ConfigTest < MiniTest::Unit::TestCase
  def test_defaults
    assert_equal '5m', ElasticRecord::Config.scroll_keep_alive
  end

  def test_models
    ElasticRecord::Config.model_names = %w(Widget)

    assert_equal [Warehouse, Widget], ElasticRecord::Config.models
  end
end
