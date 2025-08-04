module ElasticRecord
  class Index
    module Settings
      def settings=(mapping)
        settings.deep_merge!(mapping)
      end

      def settings
        @settings ||= ElasticRecord::Config.default_index_settings.deep_dup
      end

      def update_settings(index_name = alias_name, settings: self.settings)
        connection.json_put "/#{index_name}/_settings", settings
      end

      def toggle_write_block(value)
        update_settings(settings: { index: { 'blocks.write': value } })
      end
    end
  end
end
