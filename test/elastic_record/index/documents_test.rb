require 'helper'

class ElasticRecord::Index::DocumentsTest < MiniTest::Test
  def teardown
    index.enable!
  end

  class InheritedWidget < Widget
    def self.base_class
      Widget
    end
  end

  def test_index_record
    record = Widget.new(id: '5', color: 'red')

    index.index_record(record)

    assert index.record_exists?('5')
    refute index.record_exists?('7')
  end

  def test_index_record_when_disabled
    record = Widget.new(id: '5', color: 'red')
    index.disable!

    index.index_record(record)
    refute index.record_exists?(record.id)
  end

  def test_index_document
    index.index_document('abc', color: 'red')

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_update_document
    index.index_document('abc', warehouse_id: '5', color: 'red')
    index.update_document('abc', color: 'blue')

    expected = {'warehouse_id' => '5', 'color' => 'blue'}
    assert_equal expected, index.get('abc', Widget.doctype)['_source']
  end

  def test_delete_document
    index.index_document('abc', color: 'red')
    assert index.record_exists?('abc')

    index.delete_document('abc')
    refute index.record_exists?('abc')

    assert_raises RuntimeError do
      index.delete_document('')
    end
  end

  def test_delete_by_query
    index.index_document('bob', name: 'bob')
    index.index_document('joe', name: 'joe')

    index.delete_by_query('query' => {query_string: {query: 'name:bob'}})

    refute index.record_exists?('bob')
    assert index.record_exists?('joe')
  end

  def test_build_scroll_enumerator
    index.index_document('bob', name: 'bob')
    index.index_document('joe', name: 'joe')

    scroll_enumerator = index.build_scroll_enumerator(search: {'query' => {query_string: {query: 'name:bob'}}})

    assert_equal 1, scroll_enumerator.total_hits
    assert_equal 1, scroll_enumerator.request_more_ids.size
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
      index.update_document '5', color: 'blue'
      index.delete_document '3'

      expected = [
        {index: {_index: index.alias_name, _type: "widget", _id: "5"}},
        {color: "green"},
        {update: {_index: "widgets", _type: "widget", _id: "5", _retry_on_conflict: 3}},
        {doc: {color: "blue"}, doc_as_upsert: true},
        {delete: {_index: index.alias_name, _type: "widget", _id: "3", _retry_on_conflict: 3}}
      ]
      assert_equal expected, index.current_bulk_batch
    end

    assert_nil index.current_bulk_batch
  end

  def test_bulk_error
    without_deferring do
      begin
        index.bulk do
          index.index_document '5', color: 'green'
          index.index_document '3', color: {'bad' => 'stuff'}
        end
        refute index.record_exists?('3')
        assert false, 'Expected ElasticRecord::BulkError'
      rescue => e
        assert_match '[{"index"', e.message
      end
    end
  end

  def test_bulk_inheritence
    without_deferring do
      index.bulk do
        InheritedWidget.elastic_index.index_document '5', color: 'green'

        expected = [
          {index: {_index: index.alias_name, _type: "widget", _id: "5"}},
          {color: "green"}
        ]
        assert_equal expected, index.current_bulk_batch
      end
    end
  end

  private

    def without_deferring
      index.disable_deferring!
      yield
      index.reset
      index.enable_deferring!
    end

    def index
      @index ||= Widget.elastic_index
    end
end
