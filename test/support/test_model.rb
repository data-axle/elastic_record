class TestModel
  include ElasticRecord::Model

  class << self
    def find(ids)
      ids.map { |id| new(id: id, color: 'red') }
    end


    def reset_index!
      elastic_connection.delete_index('widgets')
      elastic_connection.create_index('widgets')
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