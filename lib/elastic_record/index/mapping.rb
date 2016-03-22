module ElasticRecord
  class Index
    module Mapping
      def mapping=(custom_mapping)
        mapping.deep_merge!(custom_mapping)
      end

      def update_mapping(index_name = alias_name)
        connection.json_put "/#{index_name}/#{type}/_mapping", type => mapping
      end

      def get_mapping(index_name = alias_name)
        json = connection.json_get "/#{index_name}/#{type}/_mapping"
        unless json.empty?
          json.values.first['mappings']
        end
      end

      def mapping
        @mapping ||= {
          properties: {
          },
          _all: {
            enabled: false
          },
          dynamic_templates: [
            {
              no_string_analyzing: {
                match: "*",
                match_mapping_type: "string",
                mapping: {
                  type: "string",
                  index: "not_analyzed",
                  doc_values: true
                }
              }
            }
          ]
        }
      end
    end
  end
end
