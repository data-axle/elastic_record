module ElasticRecord
  class Version
    extend ElasticConnection

    def self.es6?
      @es6 ||= elastic_connection.json_get('/')
        .dig('version', 'number')
        &.start_with?('6.')
    end
  end
end
