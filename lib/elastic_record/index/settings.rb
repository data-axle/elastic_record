module ElasticRecord
  class Index
    module Settings
      def settings=(mapping)
        settings.deep_merge!(mapping)
      end

      def settings
        @settings ||=
          begin
            result = {}

            if (analysis = analysis_body).any?
              result['analysis'] = analysis
            end

            result
          end
      end

      def update_settings(index_name = alias_name)
        connection.json_put "/#{index_name}/_settings", settings
      end

      def analysis_body
        doctype.analysis
      end
    end
  end
end
