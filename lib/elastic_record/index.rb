require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'

module ElasticRecord
  class Index
    include Manage
    include Mapping

    attr_accessor :model

    def initialize(model)
      @model = model
    end

    def name
      model.model_name.collection
    end

    def type
      model.model_name.element
    end
  end
end