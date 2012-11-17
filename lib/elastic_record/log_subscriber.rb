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

      if payload[:request].body
        request_log << " '#{payload[:request].body}'"
      end

      debug "(%.1fms) #{request_log}" % [event.duration]
    end

    # def logger
    #   Rails.logger
    # end
  end
end

ElasticRecord::LogSubscriber.attach_to :elastic_record
