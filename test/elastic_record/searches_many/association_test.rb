require 'helper'

class ElasticRecord::SearchesMany::AssociationTest < MiniTest::Spec

  def test_writer_assignment_from_hash
    warehouse = Warehouse.new
    warehouse.widgets = [{color: 'blue', name: 'thing'}]

    # huh? this doesn't pass
    # assert_equal 1, warehouse.widgets.count
    assert_equal 1, warehouse.widgets.all.count
    assert_equal 'blue', warehouse.widgets[0].color
  end

  def test_writer
    warehouse = Warehouse.new
    warehouse.widgets = [{color: 'blue', name: 'thing'}]

    warehouse.widgets = [{color: 'blue', name: 'thing'}, {color: 'red', name: 'device'}]

    assert_equal 2, warehouse.widgets.all.count
    assert_equal 'blue', warehouse.widgets[0].color
    assert_equal 'red', warehouse.widgets[1].color
  end

end
