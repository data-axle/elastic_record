class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets do |t|
      t.string :warehouse_id
      t.string :name
      t.string :color
      t.integer :price
      t.jsonb :widget_part
      t.integer :parent_id
    end
  end
end
