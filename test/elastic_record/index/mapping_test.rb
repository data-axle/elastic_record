require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Unit::TestCase
  def test_delete_mapping
    index_name = index.create
    index.get_mapping(index_name)

    index.delete_mapping(index_name)
    
    assert_raises ElasticRecord::ConnectionError do
      index.get_mapping(index_name)
    end
  end

  def test_default_mapping
    mapping = index.mapping

    refute_nil mapping[:_source]
    refute_nil mapping[:properties]
  end

  def test_merge_mapping
    index = ElasticRecord::Index.new(Widget)
    index.mapping.clear
    index.mapping[:properties] = {field: {type: 'string'}}
    custom = {properties: {field: {type: 'integer'}}, other: 'stuff'}
    index.mapping = custom
    assert_equal custom, index.mapping
  end

  private
    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end