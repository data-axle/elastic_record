module ElasticRecord
  module ElasticConnection
    extend ActiveSupport::Concern

    included do
      mattr_accessor :elastic_connection_cache, instance_writer: false
    end

    class_methods do
      def elastic_connection
        self.elastic_connection_cache ||= ElasticRecord::Connection.new(ElasticRecord::Config.servers, ElasticRecord::Config.connection_options)
      end
    end
  end
end
