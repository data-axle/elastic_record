class Widget < ActiveRecord::Base
  include ElasticRecord::Model
  self.elastic_index.partial_updates = true

  belongs_to :warehouse
  validates :color, format: {with: /[a-z]/}

  self.doctype.mapping[:properties].update(
    'name' => {
      type: 'text', index: false,
      fields: {
        analyzed: {type: 'text', index: true}
      }
    },
    'color' => {
      type: 'text', index: false
    },
    'warehouse_id' => {
      type: 'text', index: false
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
