module ElasticRecord
  class Config
    class << self
      def servers=(value)
        @servers = value
      end

      def servers
        @servers
      end

      def connection_options
        @connection_options ||= {}
      end

      def connection_options=(options)
        @connection_options = options
      end

      def model_names=(names)
        @model_names = names
      end

      def models
        @models ||= @model_names.map { |model_name| model_name.constantize }
      end
    end
  end
end
