require 'helper'

class ElasticRecord::RelationTest < MiniTest::Test
  def test_count
    original_count = Widget.elastic_relation.count
    Widget.create(color: 'red')
    Widget.create(color: 'blue')

    assert_equal 2, Widget.elastic_relation.count - original_count
  end

  def test_aggregations
    Widget.create(color: 'red')
    Widget.create(color: 'blue')

    aggregations = Widget.elastic_relation.aggregate('popular_colors' => {'terms' => {'field' => 'color'}}).aggregations

    assert_equal 2, aggregations['popular_colors'].buckets.size
    assert_equal %w(red blue).to_set, aggregations['popular_colors'].buckets.map(&:key).to_set
  end

  def test_explain
    Widget.create(color: 'blue')

    # explain = Widget.elastic_relation.filter(color: 'blue').explain('10')
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
    Widget.create(color: 'red')
    Widget.create(color: 'blue')

    assert_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'red')
    refute_equal Widget.elastic_relation.filter(color: 'red'), Widget.elastic_relation.filter(color: 'blue')
    assert_equal [], Widget.elastic_relation.filter(color: 'magenta')
    assert_equal Widget.elastic_relation.filter(color: 'magenta'), []
  end

  def test_inspect
    assert_equal [].inspect, Widget.elastic_relation.filter(color: 'magenta').inspect
  end
end
