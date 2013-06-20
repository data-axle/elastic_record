require 'helper'

class ElasticRecord::SearchesMany::AssociationTest < MiniTest::Spec

  def test_writer_assignment_from_hash
    warehouse = Warehouse.new
    warehouse.widgets = [{color: 'blue', name: 'thing'}]

    assert_equal 1, warehouse.widgets.all.count
    assert_equal 'blue', warehouse.widgets[0].color
  end

  def test_writer
    warehouse = Warehouse.new
    warehouse.widgets = [{color: 'blue', name: 'thing'}]
    assert_equal 1, warehouse.widgets.all.count

    warehouse.widgets = [ {color: 'red', name: 'device'}, {color: 'blue', name: 'thing'} ]
    assert_equal 2, warehouse.widgets.all.count
    assert_equal 'red', warehouse.widgets[0].color
    assert_equal 'blue', warehouse.widgets[1].color
  end

end
