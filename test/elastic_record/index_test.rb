require 'helper'

class ElasticRecord::IndexTest < MiniTest::Spec
  def test_model_name
    index = Widget.elastic_index

    assert_equal 'widgets', index.alias_name
    assert_equal 'widget', index.type
  end
end