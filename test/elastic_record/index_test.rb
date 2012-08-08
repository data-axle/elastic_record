require 'helper'

class ElasticRecord::IndexTest < MiniTest::Spec
  def test_elastic_connection
    index = Widget.elastic_index

    assert_equal 'widget', index.type
    assert_equal 'widgets', index.name
  end
end