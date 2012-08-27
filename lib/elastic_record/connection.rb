module ElasticRecord
  module Connection
    def elastic_connection
      @elastic_connection ||= ElasticSearch.new(
        ElasticRecord::Config.servers,
        ElasticRecord::Config.connection_options.merge(index: elastic_index.name, type: elastic_index.type)
      )
    end

    def elastic_connection=(connection)
      @elastic_connection = connection
    end
  end
end