require 'helper'

class ElasticRecord::SearchingTest < MiniTest::Test
  def setup
    super
    ScopedWidget.elastic_index.enable_deferring!
  end

  def teardown
    super
    ScopedWidget.elastic_index.reset_deferring!
  end

  def test_elastic_relation
    relation = Widget.elastic_relation

    assert_equal Widget, relation.klass
    assert_equal Widget.arelastic, relation.arelastic
  end

  def test_elastic_search
    widget = Widget.create!(color: 'red')
    assert_equal widget, Widget.elastic_search.filter(color: 'red').first
    assert_equal widget, Widget.es.filter(color: 'red').first
  end

  class ScopedWidget < Widget
    elastic_scope :by_color, ->(color) { elastic_search.filter(color: color) } do
      def negative_offset
        -offset_value
      end
    end
  end

  def test_elastic_scope
    ScopedWidget.create!(color: :blue)
    relation = ScopedWidget.by_color('blue')

    ScopedWidget.elastic_index.refresh
    assert_equal ScopedWidget.elastic_relation.filter(color: 'blue'), relation
    assert_equal -5, relation.offset(5).negative_offset
  end
end
