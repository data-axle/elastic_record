class Widget
  include TestModel

  validates :color, format: {with: /[a-z]/}

  define_attributes [:name, :color, :warehouse_id]

  self.elastic_index.has_percolator = true

  self.elastic_index.mapping[:properties].update(
    'name' => {
      type: 'keyword',
      fields: {
        analyzed: {type: 'text'}
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

  def warehouse=(other)
    self.warehouse_id = other.id
  end
end
