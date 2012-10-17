require 'helper'

class ElasticRecord::SearchesMany::AutosaveTest < ActiveSupport::TestCase
  # def test_save_associations_callback
  #   warehouse = build :warehouse
  #   widget = build :widget, warehouse: nil
  #   warehouse.widgets = [widget]
  #   assert widget.new_record?
  # 
  #   warehouse.save
  # 
  #   assert widget.persisted?
  # end
  # 
  # def test_validate_associations_callback
  #   warehouse = build :warehouse
  #   link = build :link, warehouse: nil, uri: 'invalid uri'
  #   warehouse.links = [link]
  # 
  #   assert warehouse.invalid?
  #   assert_equal ["is invalid"], warehouse.errors['links.uri']
  # end
  # 
  # def test_mark_for_destruction
  #   widget = build_stubbed :widget
  # 
  #   widget.mark_for_destruction
  # 
  #   assert widget.marked_for_destruction?
  # end
end