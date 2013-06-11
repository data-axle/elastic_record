class Option
  include TestModel

  define_attributes [:name, :widget_id]

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

  def initialize(*args)
    super
    self.class._test_cache << self
  end

  def widget=(other)
    self.widget_id = other.id
  end
end
