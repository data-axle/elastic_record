module ElasticRecord
  module NameCache
    extend ActiveSupport::Concern

    included do
      class_attribute :cached_index_name
      class_attribute :index_name_cache_time
      self.index_name_cache_time = 0
    end

    class_methods do
      def current_index_name
        if (Time.now - index_name_cache_time) < 60
          cached_index_name
        else
          self.index_name_cache_time = Time.now
          aliased_names = elastic_connection.json_get("/_alias/#{elastic_index.alias_name}").keys
          self.cached_index_name = aliased_names.first
        end
      end
    end
  end
end
