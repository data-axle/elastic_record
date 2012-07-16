module ElasticRecord
  module Connection
    def elastic_connection=(connection)
      @elastic_connection = connection
    end

    def elastic_connection
      @elastic_connection
    end
  end
end
    