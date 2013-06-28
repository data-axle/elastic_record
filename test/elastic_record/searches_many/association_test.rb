require 'helper'

class ElasticRecord::SearchesMany::AssociationTest < MiniTest::Spec

  def test_writer_assignment_from_hash
    warehouse = Warehouse.new
    warehouse.widgets = [{color: 'blue', name: 'thing'}]

    assert_equal 1, warehouse.widgets.all.count
    expected = {
      'color' => 'blue',
      'name' => 'thing',
      'warehouse_id' => warehouse.id,
    }
    assert_equal expected, warehouse.widgets[0].attributes
  end

  def test_writer
    warehouse = Warehouse.new

    warehouse.widgets = [{color: 'blue', name: 'thing'}]

    assert_equal 1, warehouse.widgets.all.count

    warehouse.widgets = [ {color: 'red', name: 'device'}, {color: 'blue', name: 'thing'} ]

    assert_equal 3, warehouse.widgets.all.count
    assert warehouse.widgets[0].marked_for_destruction?
    refute warehouse.widgets[1].marked_for_destruction?
    refute warehouse.widgets[2].marked_for_destruction?

    expected = {
      'color' => 'red',
      'name' => 'device',
      'warehouse_id' => warehouse.id,
    }
    assert_equal expected, warehouse.widgets[1].attributes

    expected = {
      'color' => 'blue',
      'name' => 'thing',
      'warehouse_id' => warehouse.id,
    }
    assert_equal expected, warehouse.widgets[2].attributes
  end

end
