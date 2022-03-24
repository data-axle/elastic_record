require 'helper'

class ElasticRecord::RelationTest < MiniTest::Test
  class SpecialRelation < ElasticRecord::Relation
  end

  def test_becomes
    parent_relation = Widget.elastic_relation.filter(color: 'red')
    became_relation = parent_relation.becomes(SpecialRelation)

    assert_kind_of SpecialRelation, became_relation
    assert_equal Widget, became_relation.klass
    assert_equal parent_relation.values, became_relation.values
    refute_equal parent_relation.values.object_id, became_relation.values.object_id
  end

  def test_count
    original_count = Widget.elastic_relation.count
    Widget.create!(color: 'red')
    Widget.create!(color: 'blue')

    assert_equal 2, Widget.elastic_relation.count - original_count
  end

  def test_aggregations
    Widget.create!(color: 'red', price: 5)
    Widget.create!(color: 'blue', price: 10)

    aggregations = Widget.elastic_relation.aggregate('popular_colors' => {'terms' => {'field' => 'color'}}).aggregations

    assert_equal 2, aggregations['popular_colors'].buckets.size
    assert_equal %w(red blue).to_set, aggregations['popular_colors'].buckets.map(&:key).to_set

    aggregations = Widget.elastic_relation.aggregate('avg_price' => {'avg' => {'field' => 'price'}}).aggregations
    assert_equal 7.5, aggregations['avg_price'].value
  end

  def test_explain
    Widget.create!(color: 'blue')

    # explain = Widget.elastic_relation.filter(color: 'blue').explain('10')
  end

  def test_to_a
    Widget.create!(color: 'red')
    Widget.create!(color: 'red')

    array = Widget.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Widget)
  end

  def test_safe_load
    Widget.create!(color: 'red')
    Widget.elastic_index.index_record(Widget.new(color: 'blue'))

    relation = Widget.elastic_relation
    assert_raises ActiveRecord::RecordNotFound do
      relation.to_a
    end
    relation.safe!
    array = relation.to_a

    assert relation.safe?
    assert_equal 1, array.size
    assert_equal 'red', array.first.color
  end

  def test_to_a_from_source
    warehouses = [Project.new(name: 'Latte'), Project.new(name: 'Americano')]
    Project.elastic_index.bulk_add(warehouses)

    array = Project.elastic_relation.to_a

    assert_equal 2, array.size
    assert array.first.is_a?(Project)
    names = array.map(&:name)
    assert_includes names, 'Latte'
    assert_includes names, 'Americano'
  end

  def test_delete_all
    project_red = Warehouse.create! name: 'Red'
    project_blue = Warehouse.create! name: 'Blue'

    Warehouse.elastic_relation.filter(name: 'Red').delete_all

    assert_nil Warehouse.find_by(id: project_red.id)
    assert_equal 0, Warehouse.elastic_relation.filter(name: 'Red').count

    refute_nil Warehouse.find_by(id: project_blue.id)
    assert_equal 1, Warehouse.elastic_relation.filter(name: 'Blue').count
  end

  def test_equal
    Widget.create!(color: 'red')
    Widget.create!(color: 'blue')

    assert_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'red')
    refute_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'blue')
    assert_equal [], Widget.elastic_relation.filter(color: 'magenta')
    assert_equal Widget.elastic_relation.filter(color: 'magenta'), []
  end

  def test_inspect
    assert_equal [].inspect, Widget.elastic_relation.filter(color: 'magenta').inspect
  end
end
