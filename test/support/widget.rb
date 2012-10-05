class Widget
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :destroy

  include ElasticRecord::Model
  include ElasticRecord::Callbacks

  self.elastic_index.mapping[:properties].update(
    name: {
      type: 'multi_field', 
      fields: {
        name: {type: 'string', index: 'not_analyzed'},
        analyzed: {type: 'string', index: 'analyzed'}
      }
    },
    color: {
      type: 'string', index: 'not_analyzed'
    }
  )
  
  class << self
    def find(ids)
      ids.map { |id| new(id: id, color: 'red') }
    end

    def anon(&block)
      Class.new(self) do
        def self.name
          'Widget'
        end

        instance_eval(&block)
      end
    end

    def base_class
      self
    end
  end

  attr_accessor :id, :name, :color
  def initialize(attributes = {})
    attributes.each do |key, val|
      send("#{key}=", val)
    end
  end

  def as_search
    {name: name, color: color}
  end
end