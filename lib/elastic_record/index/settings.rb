module ElasticRecord
  class Index
    module Settings
      def settings=(mapping)
        settings.deep_merge!(mapping)
      end

      def settings
        @settings ||= begin
          result = ElasticRecord::Config.default_index_settings.deep_dup
          result['analysis'] = analysis if analysis.any?
          result
        end
      end

      def update_settings(index_name = alias_name, settings: self.settings)
        connection.json_put "/#{index_name}/_settings", settings
      end
    end
  end
end
