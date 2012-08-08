require 'helper'

class ElasticRecord::RelationTest < MiniTest::Spec
  def setup
    Widget.reset_index!
    create_widgets
  end

  def test_to_hits
    assert Widget.elastic_relation.to_hits.is_a?(ElasticSearch::Api::Hits)
  end

  def test_to_ids
    assert_equal ['5', '10'], Widget.elastic_relation.to_ids
  end

  def test_to_a
    array = Widget.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Widget)
  end

  def test_count
    assert_equal 2, Widget.elastic_relation.count
  end

  def test_facets
    facets = Widget.elastic_relation.facet(Widget.arelastic.facet['popular_colors'].terms('color')).facets

    assert_equal 2, facets['popular_colors']['total']
  end

  def test_equal
    assert(Widget.elastic_relation.filter(color: 'green') == Widget.elastic_relation.filter(color: 'green'))
    assert(Widget.elastic_relation.filter(color: 'green') != Widget.elastic_relation.filter(color: 'blue'))

    assert(Widget.elastic_relation.filter(color: 'magenta') == [])
  end

  def test_inspect
    assert_equal [].inspect, Widget.elastic_relation.filter(color: 'magenta').inspect
  end

  private
    def create_widgets
      Widget.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
      Widget.elastic_connection.index({'widget' => {'color' => 'blue'}}, {index: 'widgets', type: 'widget', id: 10})
      
      Widget.elastic_connection.refresh
    end
end