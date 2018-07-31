require 'helper'

class ElasticRecord::Relation::HitsTest < MiniTest::Test
  def test_to_hits
    # assert Widget.elastic_relation.search_results.is_a?(ElasticSearch::Api::Hits)
  end

  def test_to_ids
    red_widget = Widget.create(color: 'red')
    blue_widget = Widget.create(color: 'red')

    assert_equal [red_widget.id.to_s, blue_widget.id.to_s].to_set, Widget.elastic_relation.to_ids.to_set
  end

  def test_to_a
    red_widget = Widget.create(color: 'red')
    blue_widget = Widget.create(color: 'red')

    array = Widget.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Widget)
  end

  def test_to_a_from_source
    warehouses = [Project.new(name: 'Latte'), Project.new(name: 'Americano')]
    result = Project.elastic_index.bulk_add(warehouses)

    array = Project.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Project)
    names = array.map(&:name)
    assert_includes names, 'Latte'
    assert_includes names, 'Americano'
  end

  def test_matching_documents_by_id
    red_query = WidgetQuery.create(color: 'red')
    blue_query = WidgetQuery.create(color: 'blue')
    expected = {
      red_query.id => [0],
      blue_query.id => [1]
    }
    matching_documents_by_id = WidgetQuery.percolate([
      { color: 'red' },
      { color: 'blue' },
      { color: 'green' }
    ]).matching_documents_by_id

    assert_equal expected, matching_documents_by_id
  end
end
