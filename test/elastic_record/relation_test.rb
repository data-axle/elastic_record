require 'helper'

class ElasticRecord::RelationTest < MiniTest::Test
  def test_count
    original_count = Widget.elastic_relation.count
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    assert_equal 2, Widget.elastic_relation.count - original_count
  end

  def test_facets
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    facets = Widget.elastic_relation.facet(Widget.arelastic.facet['popular_colors'].terms('color')).facets

    assert_equal 2, facets['popular_colors']['total']
  end

  def test_aggregations
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    aggregations = Widget.elastic_relation.aggregate('popular_colors' => {'terms' => {'field' => 'color'}}).aggregations

    assert_equal 2, aggregations['popular_colors']['buckets'].size
    assert_equal %w(red blue).to_set, aggregations['popular_colors']['buckets'].map { |bucket| bucket['key'] }.to_set
  end

  def test_explain
    create_widgets [Widget.new(id: 10, color: 'blue')]

    # explain = Widget.elastic_relation.filter(color: 'blue').explain('10')
  end

  def test_to_hits
    # assert Widget.elastic_relation.search_results.is_a?(ElasticSearch::Api::Hits)
  end

  def test_to_ids
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    assert_equal ['5', '10'].to_set, Widget.elastic_relation.to_ids.to_set
  end

  def test_to_a
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    array = Widget.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Widget)
  end

  def test_equal
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    assert_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'red')
    refute_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'blue')
    assert_equal [], Widget.elastic_relation.filter(color: 'magenta')
    assert_equal Widget.elastic_relation.filter(color: 'magenta'), []
  end

  def test_inspect
    assert_equal [].inspect, Widget.elastic_relation.filter(color: 'magenta').inspect
  end

  private
    def create_widgets(widgets)
      Widget.elastic_index.bulk_add(widgets)
    end
end
