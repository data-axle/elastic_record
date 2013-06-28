require 'helper'

class ElasticRecord::SearchesMany::AutosaveTest < MiniTest::Unit::TestCase
  def test_save_associations_autosave_callback
    warehouse = Warehouse.new
    widget = Widget.new
    warehouse.widgets = [widget]
    assert warehouse.new_record?
    assert widget.new_record?

    warehouse.save

    assert widget.persisted?
  end

  def test_validate_associations_autosave_callback
    warehouse = Warehouse.new
    widget = Widget.new color: 123
    warehouse.widgets = [widget]

    assert warehouse.invalid?
    assert_equal ["is invalid"], warehouse.errors['widgets.color']
  end

  def test_mark_for_destruction
    widget = Widget.new

    widget.mark_for_destruction

    assert widget.marked_for_destruction?
  end
end
