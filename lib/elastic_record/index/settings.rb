module ElasticRecord
  class Index
    module Settings
      def settings=(mapping)
        settings.deep_merge!(mapping)
      end

      def settings
        @settings ||= {}
      end

      def update_settings(index_name = alias_name)
        connection.json_put "/#{index_name}/_settings", settings
      end
    end
  end
end
