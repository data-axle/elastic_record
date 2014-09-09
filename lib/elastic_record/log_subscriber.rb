module ElasticRecord
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current["elastic_record_request_runtime"] = value
    end

    def self.runtime
      Thread.current["elastic_record_request_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def request(event)
      self.class.runtime += event.duration

      payload = event.payload
      request_log = "#{payload[:request].method} #{payload[:http].address}:#{payload[:http].port}#{payload[:request].path}"

      if (payload_body = payload[:request].body)
        request_log <<
          if payload_body.size > 420
            " '#{payload_body[0...200]}[CUT #{payload_body.size - 400} chars]#{payload_body[-200..-1]}'"
          else
            " '#{payload_body}'"
          end
      end

      debug "(#{event.duration.round(1)}ms) #{request_log}"
    end

    # def logger
    #   Rails.logger
    # end
  end
end

ElasticRecord::LogSubscriber.attach_to :elastic_record
