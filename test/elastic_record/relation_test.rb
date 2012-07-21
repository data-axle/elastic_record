require 'helper'

class ElasticRecord::RelationTest < MiniTest::Spec
  def setup
    Widget.reset_index!
    create_widgets
  end

  def test_to_hits
    assert Widget.relation.to_hits.is_a?(ElasticSearch::Api::Hits)
  end

  def test_to_ids
    assert_equal ['5', '10'], Widget.relation.to_ids
  end

  def test_to_a
    array = Widget.relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Widget)
  end

  def test_count
    assert_equal 2, Widget.relation.count
  end

  def test_facets
    facets = Widget.relation.facet(Widget.arelastic.facet['popular_colors'].terms('color')).facets

    assert_equal 2, facets['popular_colors']['total']
  end

  def test_equal
    assert_equal Widget.relation.filter(color: 'green'), Widget.relation(color: 'green')
    assert false
  end

  def test_inspect
    assert false
  end

  private
    def create_widgets
      Widget.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
      Widget.elastic_connection.index({'widget' => {'color' => 'blue'}}, {index: 'widgets', type: 'widget', id: 10})
      
      Widget.elastic_connection.refresh
    end
end