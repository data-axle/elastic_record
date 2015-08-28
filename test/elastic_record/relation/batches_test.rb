require 'helper'

class ElasticRecord::Relation::BatchesTest < MiniTest::Test
  def setup
    super
    create_widgets
  end

  def test_find_each
    results = []
    Widget.elastic_relation.find_each do |widget|
      results << widget.id
    end
    assert_equal ['5', '10', '15'].to_set, results.to_set
  end

  def test_find_ids_in_batches
    results = []
    Widget.elastic_relation.find_ids_in_batches do |ids|
      results << ids
    end
    assert_equal [['5', '10', '15'].to_set], results.map(&:to_set)
  end

  def test_find_ids_in_batches_with_size
    results = []
    Widget.elastic_relation.find_ids_in_batches(batch_size: 2) do |ids|
      results << ids
    end

    assert_equal 2, results.size
    assert_equal 2, results[0].size
    assert_equal 1, results[1].size
    assert_equal ['5', '10', '15'].to_set, results.flatten.to_set
  end

  def test_find_in_batches
    results = []
    Widget.elastic_relation.find_in_batches do |widgets|
      results << widgets.map(&:id)
    end
    assert_equal [['5', '10', '15'].to_set], results.map(&:to_set)
  end

  def test_find_in_batches_with_scope
    results = []
    Widget.elastic_relation.filter(color: %w(red blue)).find_in_batches do |widgets|
      results << widgets.map(&:id)
    end
    assert_equal [['5', '10'].to_set], results.map(&:to_set)
  end

  def test_find_offset_shards
    create_additional_widgets

    results = []
    Widget.elastic_relation.find_ids_in_batches(batch_size: 1) do |ids|
      results << ids
    end

    assert_equal 8, results.size
    results.each do |r| assert_equal 1, r.size end
    assert_equal ['5', '10', '15', '20', '25', '30', '35', '40'].to_set, results.flatten.to_set
  end

  def test_create_scan_search
    scan_search = Widget.elastic_relation.create_scan_search

    assert_equal 3, scan_search.total_hits
    refute_nil scan_search.scroll_id
    assert_equal 3, scan_search.request_more_ids.size
  end

  def test_each_should_not_be_used
    results = []
    Widget.elastic_relation.each do |widget|
      results << widget.id
    end

    assert_equal ['5', '10', '15'].to_set, results.to_set
  end

  private
    def create_widgets
      Widget.elastic_index.bulk_add [
        Widget.new(id: 5, color: 'red'),
        Widget.new(id: 10, color: 'blue'),
        Widget.new(id: 15, color: 'green'),
      ]
    end

    def create_additional_widgets
      Widget.elastic_index.bulk_add [
          Widget.new(id: 20, color: 'yellow'),
          Widget.new(id: 25, color: 'violet'),
          Widget.new(id: 30, color: 'indigo'),
          Widget.new(id: 35, color: 'orange'),
          Widget.new(id: 40, color: 'black'),
      ]
    end
end
