module ElasticRecord
  class Index
    module Mapping
      def mapping=(mapping)
        mapping.deep_merge!(mapping)
      end

      def mapping
        @mapping ||= {
          _source: {
            enabled: false
          },
          properties: {
            created_at: {type: "date", index: "not_analyzed", format: "dateOptionalTime"},
            updated_at: {type: "date", index: "not_analyzed", format: "dateOptionalTime"}
          },
          dynamic_templates: [
            {
              no_string_analyzing: {
                match: "*",
                match_mapping_type: "string",
                mapping: {
                  type: "string",
                  index: "not_analyzed"
                }
              }
            }
          ]
        }
      end
    end
  end
end