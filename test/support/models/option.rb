class Option
  include TestModel

  define_attributes [:name, :widget_id, :color]

  searches_many :options

  self.elastic_index.mapping[:properties].update(
    name: {
      type: 'multi_field', 
      fields: {
        name: {type: 'string', index: 'not_analyzed'},
        analyzed: {type: 'string', index: 'analyzed'}
      }
    },
    widget_id: {
      type: 'string', index: 'not_analyzed'
    }
  )

  class << self
    def anon(&block)
      Class.new(self) do
        def self.name
          'Option'
        end

        instance_eval(&block)
      end
    end
  end

  def widget=(other)
    self.widget_id = other.id
  end
end
