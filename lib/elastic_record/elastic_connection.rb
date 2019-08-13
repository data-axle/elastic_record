module ElasticRecord
  module ElasticConnection
    def elastic_connection
      self.elastic_connection_cache ||= ElasticRecord::Connection.new(ElasticRecord::Config.servers, ElasticRecord::Config.connection_options)
    end
  end
end
