module ElasticRecord
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request(event)
      response = event.payload[:response]
      info "#{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]} (%.1fms)" % [event.duration] 
      # info "--> %d %s %d (%.1fms)" % [response.code, response.message, response.body.to_s.length, event.duration]
    end

    # def logger
    #   Rails.logger
    # end
  end
end

ElasticRecord::LogSubscriber.attach_to :elastic_record