class Widget < ActiveRecord::Base
  include ElasticRecord::Model
  self.elastic_index.partial_updates = true

  # validates :color, format: {with: /[a-z]/}
  belongs_to :warehouse
  has_many :child_widgets, class_name: 'Widget', foreign_key: :parent_id

  class WidgetPart
    include ElasticRecord::Model
    attr_accessor :name
  end

  self.elastic_index.mapping_type = 'widget'
  self.elastic_index.mapping[:properties].update(
    'name' => {
      type: 'text',
      fields: {
        raw: { type: 'keyword' }
      }
    },
    'color' => {
      type: 'keyword'
    },
    'warehouse_id' => {
      type: 'keyword'
    },
    'price' => {
      type: 'long'
    },
    'widget_part' => {
      type: 'object',
      properties: {
        'name' => { type: 'keyword' }
      }
    },
    'child_widgets' => {
      type: 'nested',
      properties: {
        'color' => { type: 'keyword' }
      }
    }
  )
end
