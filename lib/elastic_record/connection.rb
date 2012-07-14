module ElasticRecord
  module Connection
    def elastic_connection
      ElasticSearch.new(ES_CONFIG["servers"], ES_CONFIG["options"].merge(index: search_index, type: search_type, server_max_requests: 100))
    end
  end
end
    