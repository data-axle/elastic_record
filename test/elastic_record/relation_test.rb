require 'helper'

class ElasticRecord::RelationTest < MiniTest::Spec
  def test_count
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    assert_equal 2, Widget.elastic_relation.count
  end

  def test_facets
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    facets = Widget.elastic_relation.facet(Widget.arelastic.facet['popular_colors'].terms('color')).facets

    assert_equal 2, facets['popular_colors']['total']
  end

  def test_explain
    create_widgets [Widget.new(id: 10, color: 'blue')]

    # explain = Widget.elastic_relation.filter(color: 'blue').explain('10')
  end

  def test_to_hits
    # assert Widget.elastic_relation.search_results.is_a?(ElasticSearch::Api::Hits)
  end

  def test_eager_loading?
    assert Widget.elastic_relation.eager_load(:options).eager_loading?
  end

  def test_eager_loading_is_not_default
    assert !Widget.elastic_relation.eager_loading?
  end

  def test_eager_load

    Option._test_cache.clear

    warehouse = Warehouse.new
    widget = Widget.new(warehouse_id: warehouse.id)
    Widget.elastic_index.bulk_add [ widget ]

    Option.elastic_index.bulk_add [
      Option.new(id:  5, widget_id: widget.id),
      Option.new(id: 10, widget_id: widget.id),
    ]

    widgets = warehouse.widgets.eager_load(:options)
    widgets.to_a

    assert_no_queries do
      assert_equal [5, 10], widgets.first.options.map(&:id)
    end

  end


  def test_to_ids
    create_widgets [Widget.new(id: 5, color: 'red'), Widget.new(id: 10, color: 'blue')]

    assert_equal ['5', '10'], Widget.elastic_relation.to_ids
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
