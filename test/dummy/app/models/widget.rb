class Widget
  include TestModel

  validates :color, format: {with: /[a-z]/}

  define_attributes [:name, :color, :warehouse_id]

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

  def warehouse=(other)
    self.warehouse_id = other.id
  end
end
