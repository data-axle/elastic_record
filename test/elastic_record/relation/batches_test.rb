require 'helper'

class ElasticRecord::Relation::BatchesTest < MiniTest::Spec
  def setup
    Widget.reset_index!
    create_widgets
  end

  def test_find_each
    results = []
    Widget.elastic_relation.find_each do |widget|
      results << widget.id
    end
    assert_equal ['5', '10', '15'].to_set, results.to_set
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

  private
    def create_widgets
      Widget.elastic_index.bulk_add [
        Widget.new(id: 5, color: 'red'),
        Widget.new(id: 10, color: 'blue'),
        Widget.new(id: 15, color: 'green'),
      ]
      
      Widget.elastic_index.refresh
    end
end