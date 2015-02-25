module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
    attr_reader :status_code
    def initialize(status_code, message)
      @status_code = status_code
      super(message)
    end
  end

  class BulkError < Error
  end
end