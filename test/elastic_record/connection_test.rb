require 'helper'

class ElasticRecord::ConnectionTest < MiniTest::Spec
  def test_elastic_connection
    connection = Widget.elastic_connection

    assert_equal Widget.elastic_index.type, connection.default_type
    assert_equal Widget.elastic_index.name, connection.default_index
  end
end