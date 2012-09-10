require 'helper'

class ElasticRecord::ConnectionTest < MiniTest::Spec
  def test_servers
    assert_equal ['foo', 'bar'], ElasticRecord::Connection.new('foo,bar').servers
    assert_equal ['foo', 'bar'], ElasticRecord::Connection.new(['foo', 'bar']).servers
  end
end