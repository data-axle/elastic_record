require 'helper'

class ElasticRecord::SearchesManyTest < MiniTest::Unit::TestCase
  def test_reader
    warehouse = Warehouse.create
    related_widget = Widget.create warehouse: warehouse
    unrelated_widget = Widget.create
  
    assert_equal [related_widget], warehouse.widgets
  end

  def test_write_with_objects
    warehouse = Warehouse.new
    widget = Widget.new
  
    warehouse.widgets = [widget]
  
    assert widget.new_record?
    assert_equal warehouse.id, widget.warehouse_id
    # assert_equal 1, warehouse.widgets_count
    # assert_in_delta Time.current, warehouse.widgets_updated_at, 5
  end

  def test_write_with_attributes
    warehouse = Warehouse.new
  
    warehouse.widgets = [
      {
        color:  'blue',
        name:   'Toy'
      }
    ]
  
    widgets = warehouse.widgets
    assert_equal 1, widgets.size
  end

  def test_write_marks_destroyed
    warehouse = Warehouse.new
    widget = Widget.create warehouse: warehouse
  
    warehouse.widgets = []
  
    association = warehouse.searches_many_association(:widgets)
    assert_equal 1, association.reader.size
    assert association.reader.first.marked_for_destruction?
  end

  def test_write_existing_record
    widget = Widget.create name: 'Toy', color: 'green'
    warehouse = Warehouse.new widgets: [widget]
  
    warehouse.widgets = [
      {
        id: widget.id,
        color:   "blue"
      }
    ]
  
    widgets = warehouse.widgets
    assert_equal 1, widgets.size
    assert_equal "blue", widgets.first.color
    assert_equal "Toy", widgets.first.name
  end

  def test_reload
    warehouse = Warehouse.create
    widget = Widget.create name: 'Toy', color: 'green', warehouse: warehouse
    assert_equal [widget], warehouse.widgets
    widget.destroy

    warehouse.reload

    assert_equal [], warehouse.widgets
  end
end