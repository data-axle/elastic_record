module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
    attr_reader :status_code, :payload

    def initialize(status_code, json_error, json_payload = nil)
      @status_code  = status_code
      error_message = build_message_hash(json_error, json_payload).to_json

      super(error_message)
    end

    private

      def build_message_hash(json_error, json_payload)
        error   = JSON.parse(json_error)
        payload = JSON.parse(json_payload || '{}')

        error.merge!('payload' => payload)
      rescue JSON::ParserError
        {
          'error'   => json_error,
          'payload' => json_payload
        }
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
