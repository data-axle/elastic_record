require 'helper'

class ElasticRecord::PersistenceOverrideTest < MiniTest::Test
  def test_wtf
    source = SourceModel.new(path: '/create')
    source.save

    found = SourceModel.filter(path: '/create').first
    assert_equal source, found
  end
end
