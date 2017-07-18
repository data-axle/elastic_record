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
          }
        }
      end
    end
  end
end
