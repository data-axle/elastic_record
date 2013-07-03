module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
  end

  class BulkError < Error
  end
end