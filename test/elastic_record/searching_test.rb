require 'helper'

class ElasticRecord::SearchingTest < MiniTest::Test
  def test_elastic_relation
    relation = Widget.elastic_relation

    assert_equal Widget, relation.klass
    assert_equal Widget.arelastic, relation.arelastic
  end

  def test_elastic_search
    widget = Widget.create(color: 'red')
    assert_equal widget, Widget.elastic_search.filter(color: 'red').first
    assert_equal widget, Widget.es.filter(color: 'red').first
  end

  def test_elastic_scope
    model = Widget.anon do
      elastic_scope :by_color, ->(color) { elastic_search.filter(color: color) } do
        def negative_offset
          -offset_value
        end
      end
    end

    relation = model.by_color('blue')

    assert_equal model.elastic_relation.filter(color: 'blue'), relation
    assert_equal -5, relation.offset(5).negative_offset
  end
end
