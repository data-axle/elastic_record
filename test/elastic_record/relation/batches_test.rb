require 'helper'

class ElasticRecord::Relation::BatchesTest < MiniTest::Test
  def setup
    super
    @red_widget   = Widget.create!(color: 'red')
    @blue_widget  = Widget.create!(color: 'blue')
    @green_widget = Widget.create!(color: 'green')
  end

  # def test_find_each
  #   results = []
  #   Widget.elastic_relation.find_each do |widget|
  #     results << widget
  #   end
  #   assert_equal [@red_widget, @blue_widget, @green_widget].to_set, results.to_set
  # end

  def test_find_hits_in_batches
    results = []
    Widget.elastic_relation.find_hits_in_batches do |hits|
      results << hits
    end
    assert_equal [@red_widget, @blue_widget, @green_widget].to_set, results.flatten.to_set
  end

  def test_find_ids_in_batches
    results = []
    Widget.elastic_relation.find_ids_in_batches do |ids|
      results << ids
    end
    assert_equal [[@red_widget.id.to_s, @blue_widget.id.to_s, @green_widget.id.to_s].to_set], results.map(&:to_set)
  end

  def test_find_in_batches
    results = []
    Widget.elastic_relation.find_in_batches do |widgets|
      results << widgets
    end
    assert_equal [[@red_widget, @blue_widget, @green_widget].to_set], results.map(&:to_set)
  end

  def test_find_in_batches_with_order
    results = []
    Widget.elastic_relation.order(color: :asc).find_in_batches do |records|
      results << records
    end

    assert_equal [[@blue_widget, @green_widget, @red_widget]], results
  end

  def test_find_in_batches_with_size
    results = []
    Widget.elastic_relation.find_in_batches(batch_size: 2) do |records|
      results << records
    end

    assert_equal 2, results.size
    assert_equal 2, results[0].size
    assert_equal 1, results[1].size
    assert_equal [@red_widget, @blue_widget, @green_widget].to_set, results.flatten.to_set
  end

  def test_find_in_batches_with_scope
    results = []
    Widget.elastic_relation.filter(color: %w(red blue)).find_in_batches do |widgets|
      results << widgets
    end
    assert_equal [[@red_widget, @blue_widget].to_set], results.map(&:to_set)
  end
end
