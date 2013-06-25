require 'helper'

class ElasticRecord::SearchesMany::CollectionProxyTest < MiniTest::Unit::TestCase
  def test_add_to_new_record
    warehouse = Warehouse.new
    widget = Widget.new
  
    warehouse.widgets << widget
  
    assert widget.new_record?
    assert_equal [widget], warehouse.widgets
  end
  
  def test_add_to_persisted_record
    warehouse = Warehouse.create
    widget = Widget.new
  
    warehouse.widgets << widget
  
    assert !widget.new_record?
    assert_equal [widget], warehouse.widgets
  end
end