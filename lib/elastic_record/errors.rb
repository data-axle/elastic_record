module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
    attr_reader :status_code, :payload

    def initialize(status_code, json_error, json_payload = nil)
      @status_code = status_code

      message = build_message(json_error, json_payload)

      super(message)
    end

    private

      def build_message(json_error, json_payload)
        error   = { elasticsearch_response: parse_or_return(json_error) }
        payload = { request_payload:        parse_or_return(json_payload) }

        error.merge(payload).to_json
      end

      def parse_or_return(json)
        JSON.parse(json.to_s)
      rescue JSON::ParserError
        json
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
