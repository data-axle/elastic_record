require 'active_support/core_ext/class/attribute'

module ElasticRecord
  class Config
    class_attribute :servers

    class_attribute :connection_options
    self.connection_options = {}

    class_attribute :model_names
    self.model_names = []

    class_attribute :scroll_keep_alive
    self.scroll_keep_alive = '5m'

    class << self
      def models
        @models ||= model_names.map { |model_name| model_name.constantize }
      end

      def settings=(settings)
        self.servers = settings['servers']

        if settings['options']
          warn("**************************************",
            "elasticsearch.yml/:options is deprecated. For example, the following:",
            "development:",
            "  servers: 127.0.0.1:9200",
            "  options:",
            "    timeout: 10",
            "    retries: 2",
            "",
            "becomes:",
            "",
            "development:",
            "  servers: 127.0.0.1:9200",
            "  timeout: 10",
            "  retries: 2",
            "**************************************")
          self.connection_options = settings['options']
        else
          self.connection_options = settings
        end

        if scroll_keep_alive = settings['scroll_keep_alive'].presence
          self.scroll_keep_alive = scroll_keep_alive
        end
      end
    end
  end
end
