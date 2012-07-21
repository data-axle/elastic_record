module ElasticRecord
  module Connection
    def elastic_connection
      ElasticRecord::Config.connection_options
      @elastic_connection ||= ElasticSearch.new(
        ElasticRecord::Config.servers,
        ElasticRecord::Config.connection_options.merge(index: model_name.collection, type: model_name.element)
      )
    end

    def elastic_connection=(connection)
      @elastic_connection = connection
    end
  end
end