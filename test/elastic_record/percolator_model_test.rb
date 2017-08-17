require 'helper'

class ElasticRecord::PercolatorModelTest < MiniTest::Test
  def test_elastic_connection
    connection = Widget.elastic_connection

    assert_equal ElasticRecord::Config.servers, connection.servers
    assert_equal ElasticRecord::Config.connection_options.symbolize_keys, connection.options
  end
end
