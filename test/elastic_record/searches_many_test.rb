require 'helper'

class ElasticRecord::SearchesManyTest < ActiveSupport::TestCase
  # def test_collection_reader
  #   warehouse = create :warehouse
  #   related_widget = create :widget, warehouse: warehouse
  #   unrelated_widget = create :widget
  # 
  #   assert_equal [related_widget], warehouse.widgets
  # end
  # 
  # def test_collection_writer
  #   warehouse = build :warehouse
  #   widget = build :widget, warehouse: nil
  # 
  #   warehouse.widgets = [widget]
  # 
  #   assert widget.new_record?
  #   assert_equal warehouse, widget.warehouse
  #   assert_equal 1, warehouse.widgets_count
  #   assert_in_delta Time.current, warehouse.widgets_updated_at, 5
  # end
  # 
  # def test_collection_write_marks_destroyed
  #   warehouse = build :warehouse
  #   widget = create :widget, warehouse: warehouse
  # 
  #   warehouse.widgets = []
  # 
  #   association = warehouse.searches_many_association(:widgets)
  #   assert_equal 1, association.reader.size
  #   assert association.reader.first.marked_for_destruction?
  # end
  # 
  # def test_collection_attributes_update
  #   warehouse = build :warehouse
  #   widget = create :widget, warehouse: warehouse, special_food: false, special_drink: false, description: "Bread"
  # 
  #   warehouse.widgets = [
  #     {
  #       id: widget.id,
  #       special_food:   "1",
  #       special_drink:  "0",
  #       description:    "Cheese"
  #     }
  #   ]
  # 
  #   widgets = warehouse.widgets
  #   assert_equal 1, widgets.size
  #   assert_equal "Cheese", widgets.first.description
  #   assert widgets.first.special_food
  #   assert !widgets.first.special_drink
  # end
  # 
  # def test_collection_attributes_create
  #   warehouse = build :warehouse
  # 
  #   warehouse.widgets = [
  #     {
  #       time_block_params: {
  #         days: {
  #           sunday:    "0",
  #           monday:    "1",
  #           tuesday:   "0",
  #           wednesday: "0",
  #           thursday:  "0",
  #           friday:    "1",
  #           saturday:  "0"
  #         },
  #         start_point:        "09:00:00",
  #         end_point:          "21:00:00",
  #         twenty_four_hours:  "0"
  #       },
  #       special_food:      "0", 
  #       special_drink:     "0",
  #       special_activity:  "0",
  #       special_other:     "0",
  #       description:       "winnar!"
  #     }
  #   ]
  # 
  #   widgets = warehouse.widgets
  #   assert_equal 1, widgets.size
  # end
end