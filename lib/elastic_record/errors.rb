module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
    attr_reader :status_code, :payload

    def initialize(status_code, message, payload = nil)
      @status_code = status_code
      super(combine(message, payload))
    end

    private

      def combine(message, payload)
        JSON.parse(message).merge(
          {
            'elastic_record_payload' => JSON.parse(payload || '{}')
          }
        ).to_json
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
