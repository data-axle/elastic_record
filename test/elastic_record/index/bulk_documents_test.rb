require 'helper'

class ElasticRecord::Index::BulkDocumentsTest < MiniTest::Test
  class InheritedWidget < Widget
    def self.base_class
      Widget
    end
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
    without_deferring(index) do
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
    without_deferring(index) do
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

  def index
    @index ||= Widget.elastic_index
  end
end
