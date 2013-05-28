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
    end
  end
end
