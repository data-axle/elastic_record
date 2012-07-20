require 'helper'

class ElasticRecord::ConnectionTest < MiniTest::Spec
  def test_elastic_connection
    connection = Widget.elastic_connection

    assert_equal 'widget', connection.default_type
    assert_equal 'widgets', connection.default_index
  end
end