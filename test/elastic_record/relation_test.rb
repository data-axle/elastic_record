require 'helper'

class ElasticRecord::RelationTest < MiniTest::Spec
  def setup
    TestModel.reset_index!
    create_widgets
  end

  def test_to_hits
    assert relation.to_hits.is_a?(ElasticSearch::Api::Hits)
  end

  def test_to_ids
    assert_equal ['5', '10'], relation.to_ids
  end

  def test_to_a
    array = relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(TestModel)
  end

  def test_count
    assert_equal 2, relation.count
  end

  def test_facets
    facets = relation.facet(relation.arelastic.facet['popular_colors'].terms('color')).facets

    assert_equal 2, facets['popular_colors']['total']
  end

  def test_delegation
    relation.filter(color: 'red').each do |widget|
      # p widget
    end
  end

  private
    def create_widgets
      TestModel.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
      TestModel.elastic_connection.index({'widget' => {'color' => 'blue'}}, {index: 'widgets', type: 'widget', id: 10})
      
      TestModel.elastic_connection.refresh
    end

    def relation
      @relation ||= ElasticRecord::Relation.new(TestModel)
    end
end