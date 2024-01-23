class Widget < ActiveRecord::Base
  include ElasticRecord::Model
  self.elastic_index.partial_updates = true

  belongs_to :warehouse, optional: true
  validates :color, format: {with: /[a-z]/}

  class WidgetPart
    include ElasticRecord::Model
    attr_accessor :name
  end

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
    }
  )
end
