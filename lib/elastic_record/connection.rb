module ElasticRecord
  module Connection
    def elastic_connection
      @elastic_connection ||= ElasticSearch.new(ElasticRecord::Config.servers, index: 'widgets', type: 'widget')
    end
  end
end