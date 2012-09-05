require 'helper'

class ElasticRecord::IndexTest < MiniTest::Spec
  def test_model_name
    index = Widget.elastic_index

    assert_equal 'widgets', index.alias_name
    assert_equal 'widget', index.type
  end

  def test_disable
    index = ElasticRecord::Index.new(Widget)

    index.disable!

    assert index.disabled
  end

  def test_enable
    index = ElasticRecord::Index.new(Widget)

    index.disable!
    index.enable!

    refute index.disabled
  end
end