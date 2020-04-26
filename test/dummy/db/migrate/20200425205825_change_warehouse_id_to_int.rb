class ChangeWarehouseIdToInt < ActiveRecord::Migration[5.1]
  def up
    change_column :widgets, :warehouse_id, "integer USING warehouse_id::integer"
  end

  def down
    change_column :widgets, :warehouse_id, :string
  end
end
