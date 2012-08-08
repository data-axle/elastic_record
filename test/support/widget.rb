class Widget
  extend ActiveModel::Naming
  include ElasticRecord::Model

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

    def reset_index!
      elastic_index.delete
      elastic_index.create
      elastic_connection.update_mapping(
        {
          properties: {
            color: {
              type: 'string',
              index: 'not_analyzed'
            }
          },
          _source: {
            enabled: false
          }
        },  
        {
          index: 'widgets'
        }
      )
    end
  end

  attr_accessor :id, :color
  def initialize(attributes = {})
    attributes.each do |key, val|
      send("#{key}=", val)
    end
  end
end