require 'active_support/core_ext/class/attribute'

module ElasticRecord
  class Config
    class_attribute :connection_options,     default: {}
    class_attribute :default_index_settings, default: {}
    class_attribute :model_names,            default: []
    class_attribute :scroll_keep_alive,      default: '2m'
    class_attribute :index_suffix

    class << self
      def models
        @models ||= model_names.map { |model_name| model_name.constantize }
      end

      def servers
        @servers
      end

      def servers=(values)
        unless values.is_a?(Array)
          values = values.split(',')
        end
        @servers = values
      end

      def settings=(settings)
        self.servers = settings['servers']
        self.index_suffix = settings['index_suffix']
        self.connection_options = settings

        if settings['scroll_keep_alive'].present?
          self.scroll_keep_alive = settings['scroll_keep_alive']
        end
      end
    end
  end
end
