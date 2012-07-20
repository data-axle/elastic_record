module ElasticRecord
  module Connection
    def elastic_connection
      @elastic_connection ||= ElasticSearch.new(ElasticRecord::Config.servers, index: model_name.collection, type: model_name.element)
    end
  end
end