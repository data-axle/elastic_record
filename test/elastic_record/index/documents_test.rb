require 'helper'

class ElasticRecord::Index::DocumentsTest < MiniTest::Spec
  def setup
    super
    
    Widget.reset_index!
  end

  def test_index_record
    record = Widget.new(id: 'abc', color: 'red')

    index.index_record(record)

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  def test_delete_record
    record = Widget.new(id: 'abc', color: 'red')

    index.index_record(record)
    assert index.record_exists?('abc')

    index.delete_record(record)
    refute index.record_exists?('abc')
  end

  def test_bulk
    record = Widget.new(id: 'abc', color: 'red')
    
    index.bulk [record]

    assert index.record_exists?('abc')
    refute index.record_exists?('xyz')
  end

  private
    def index
      @index ||= Widget.elastic_index
    end
end