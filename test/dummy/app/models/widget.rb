class Widget < ActiveRecord::Base
  include ElasticRecord::Model

  belongs_to :warehouse
  validates :color, format: {with: /[a-z]/}

  self.doctype.mapping[:properties].update(
    'name' => {
      type: 'string', index: 'not_analyzed',
      fields: {
        analyzed: {type: 'string', index: 'analyzed'}
      }
    },
    'color' => {
      type: 'string', index: 'not_analyzed'
    },
    'warehouse_id' => {
      type: 'string', index: 'not_analyzed'
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
