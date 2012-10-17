require 'helper'

class ElasticRecord::SearchesManyTest < MiniTest::Spec
  def test_collection_reader
    warehouse = Warehouse.create
    related_widget = Widget.create warehouse: warehouse
    unrelated_widget = Widget.create
  
    assert_equal [related_widget], warehouse.widgets
  end

  def test_collection_writer
    warehouse = Warehouse.new
    widget = Widget.new
  
    warehouse.widgets = [widget]
  
    assert widget.new_record?
    assert_equal warehouse.id, widget.warehouse_id
    # assert_equal 1, warehouse.widgets_count
    # assert_in_delta Time.current, warehouse.widgets_updated_at, 5
  end

  def test_collection_write_marks_destroyed
    warehouse = Warehouse.new
    widget = Widget.create warehouse: warehouse
  
    warehouse.widgets = []
  
    association = warehouse.searches_many_association(:widgets)
    assert_equal 1, association.reader.size
    assert association.reader.first.marked_for_destruction?
  end

  def test_collection_attributes_update
    warehouse = Warehouse.new
    widget = Widget.create warehouse: warehouse, name: 'Toy', color: 'green'
  
    warehouse.widgets = [
      {
        id: widget.id,
        color:   "blue"
      }
    ]
  
    widgets = warehouse.widgets
    assert_equal 1, widgets.size
    assert_equal "blue", widgets.first.color
    assert_equal "Toy", widgets.first.color
  end

  def test_collection_attributes_create
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
end