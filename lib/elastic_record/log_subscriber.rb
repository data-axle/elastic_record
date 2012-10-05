module ElasticRecord
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request(event)
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