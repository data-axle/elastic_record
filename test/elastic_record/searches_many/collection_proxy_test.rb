require 'helper'

class ElasticRecord::SearchesMany::CollectionProxyTest < ActiveSupport::TestCase
  test "add to new_record" do
    warehouse = Warehouse.new
    widget = Widget.new
  
    warehouse.widgets << widget
  
    assert widget.new_record?
    assert_equal [widget], warehouse.widgets
  end
  
  test "add to persisted record" do
    warehouse = Warehouse.create
    widget = Widget.new
  
    warehouse.widgets << widget
  
    assert !widget.new_record?
    assert_equal [widget], warehouse.widgets
  end
end