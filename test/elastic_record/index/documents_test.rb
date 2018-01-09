require 'helper'

class ElasticRecord::Index::DocumentsTest < MiniTest::Test
  def test_index_record
    record = Widget.new(id: '5', color: 'red')

    index.index_record(record)

    assert index.record_exists?('5')
    refute index.record_exists?('7')
  end

  def test_index_record_without_id
    index = Warehouse.elastic_index
    without_deferring(index) do
      warehouse = Warehouse.new(name: 'Amazon')
      result = index.index_record(warehouse)

      assert index.record_exists?(result['_id'])
      refute index.record_exists?('xyz')
    end
  end

  def test_index_document
    index.index_document('abc', color: 'red')

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_index_document_without_id
    index = Warehouse.elastic_index
    without_deferring(index) do
      result = index.index_document(nil, name: 'red')

      assert index.record_exists?(result['_id'])
      refute index.record_exists?('xyz')
    end
  end

  def test_update_document
    index.index_document('abc', warehouse_id: '5', color: 'red')
    index.update_document('abc', color: 'blue')

    expected = {'warehouse_id' => '5', 'color' => 'blue'}
    assert_equal expected, index.get('abc', Widget.doctype)['_source']

    assert_raises RuntimeError do
      index.update_document(nil, color: 'blue')
    end
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

  private

    def without_deferring(index)
      index.disable_deferring!
      yield
      index.reset
      index.enable_deferring!
    end

    def index
      @index ||= Widget.elastic_index
    end
end
