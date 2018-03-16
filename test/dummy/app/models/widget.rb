class Widget < ActiveRecord::Base
  include ElasticRecord::Model
  self.elastic_index.partial_updates = true

  belongs_to :warehouse
  validates :color, format: {with: /[a-z]/}

  self.doctype.mapping[:properties].update(
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
    }
  )

  class << self
    def anon(&block)
      Class.new(self) do
        def self.name
          'Widget'
        end

        instance_eval(&block)
      end
    end
  end
end
