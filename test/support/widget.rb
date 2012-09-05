class Widget
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :destroy

  include ElasticRecord::Model

  self.elastic_index.mapping[:properties].update(color: {
    type: 'string',
    index: 'not_analyzed'
  })

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
  end

  attr_accessor :id, :color
  def initialize(attributes = {})
    attributes.each do |key, val|
      send("#{key}=", val)
    end
  end

  def as_search
    {color: color}
  end
end