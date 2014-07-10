require 'helper'

class ElasticRecord::Index::DocumentsTest < MiniTest::Test
  class InheritedWidget < Widget
    def self.base_class
      Widget
    end
  end

  def setup
    super
    index.disable_deferring!
    index.reset
  end

  def test_index_record
    record = Widget.new(id: '5', color: 'red')

    index.index_record(record)

    assert index.record_exists?('5')
    refute index.record_exists?('7')
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

  def test_delete_by_query
    index.index_document('bob', name: 'bob')
    index.index_document('joe', name: 'joe')

    index.delete_by_query(query_string: {query: 'name.analyzed:bob'})

    refute index.record_exists?('bob')
    assert index.record_exists?('joe')
  end

  def test_bulk_add
    record = Widget.new(id: 'abc', color: 'red')

    index.bulk_add [record]

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_bulk
    assert_nil index.instance_variable_get(:@_batch)

    index.bulk do
      index.index_document '5', color: 'green'
      index.delete_document '3'

      expected = [
        {index: {_index: "widgets", _type: "widget", _id: "5"}},
        {color: "green"},
        {delete: {_index: "widgets", _type: "widget", _id: "3"}}
      ]
      assert_equal expected, index.current_bulk_batch
    end

    assert_nil index.current_bulk_batch
  end

  def test_bulk_error
    index.bulk do
      index.index_document '5', color: 'green'
      index.index_document '3', color: {'bad' => 'stuff'}
    end
    assert false, 'Expected ElasticRecord::BulkError'
  rescue => e
    assert_match '[{"index"', e.message
  end

  def test_bulk_inheritence
    index.bulk do
      InheritedWidget.elastic_index.index_document '5', color: 'green'

      expected = [
        {index: {_index: "widgets", _type: "widget", _id: "5"}},
        {color: "green"}
      ]
      assert_equal expected, index.current_bulk_batch
    end
  end

  private

    def index
      @index ||= Widget.elastic_index
    end
end