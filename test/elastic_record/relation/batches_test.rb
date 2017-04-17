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

  def test_find_with_batch_size
    results = []
    Widget.elastic_relation.find_ids_in_batches(batch_size: 1) do |ids|
      results << ids
    end

    assert_equal 3, results.size
    results.each { |r| assert_equal 1, r.size }
    assert_equal ['5', '10', '15'].to_set, results.flatten.to_set
  end

  def test_each_should_not_be_used_without_limit
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [String])
    ActiveSupport::Deprecation.stub(:warn, mock) do
      results = []
      Widget.elastic_relation.each do |widget|
        results << widget.id
      end

      assert_equal ['5', '10', '15'].to_set, results.to_set
    end

    mock.verify

    results = []
    Widget.elastic_relation.limit(3).each do |widget|
      results << widget.id
    end

    assert_equal ['5', '10', '15'].to_set, results.to_set
  end

  private
    def create_widgets
      Widget.elastic_index.delete_all
      Widget.elastic_index.bulk_add [
        Widget.new(id: 5, color: 'red'),
        Widget.new(id: 10, color: 'blue'),
        Widget.new(id: 15, color: 'green'),
      ]
    end
end
