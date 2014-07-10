require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Test
  def test_delete_mapping
    index_name = index.create
    refute_nil index.get_mapping(index_name)['widget']

    index.delete_mapping(index_name)

    assert_nil index.get_mapping(index_name)
  end

  def test_default_mapping
    mapping = index.mapping

    refute_nil mapping[:_source]
    refute_nil mapping[:properties]
  end

  def test_merge_mapping
    index.mapping.clear
    index.mapping[:properties] = {color: {type: 'string'}}

    custom = {properties: {color: {type: 'integer'}}, other: 'stuff'}
    index.mapping = custom

    assert_equal custom, index.mapping
  end

  private
    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
