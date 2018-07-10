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

      def update_settings(index_name = alias_name, settings: self.settings)
        connection.json_put "/#{index_name}/_settings", settings
      end

      def analysis_body
        doctypes.each_with_object({}) do |doctype, result|
          result.deep_merge!(doctype.analysis)
        end
      end
    end
  end
end
