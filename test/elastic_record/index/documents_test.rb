require 'helper'

class ElasticRecord::Index::DocumentsTest < MiniTest::Spec
  def setup
    super
    index.disable_deferring!
    index.reset
  end

  def test_index_document
    index.index_document('abc', color: 'red')

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_delete_document
    index.index_document('abc', color: 'red')
    assert index.record_exists?('abc')

    index.delete_document('abc')
    refute index.record_exists?('abc')
  end

  def test_bulk_add
    record = Widget.new(id: 'abc', color: 'red')
    
    index.bulk_add [record]

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_bulk
    assert_nil index.instance_variable_get(:@batch)

    index.bulk do
      index.index_document '5', color: 'green'
      index.delete_document '3'

      expected = [
        {index: {_index: "widgets", _type: "widget", _id: "5"}},
        {color: "green"},
        {delete: {_index: "widgets", _type: "widget", _id: "3"}}
      ]
      assert_equal expected, index.instance_variable_get(:@batch)
    end

    assert_nil index.instance_variable_get(:@batch)
  end

  private
    def index
      @index ||= Widget.elastic_index
    end
end