module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
    attr_reader :status_code, :payload
    def initialize(status_code, message, payload = nil)
      @status_code = status_code
      message = "#{message} (for payload '#{payload}')" if payload
      super(message)
    end
  end

  class BulkError < Error
  end

  class ExpiredScrollError < Error
  end

  class ExpiredPointInTime < Error
  end

  class InvalidScrollError < Error
  end

  class InvalidPointInTimeError < Error
  end
end
