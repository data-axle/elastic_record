module ElasticRecord
  class Version
    include Model

    def self.es6?
      @es6_mode ||= elastic_connection.json_get('/')
        .dig('version', 'number')
        .start_with?('6.')
    end
  end
end
