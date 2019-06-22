module ElasticRecord
  class Index
    module Mapping
      attr_accessor :mapping

      DEFAULT_MAPPING = {
        properties: {
        }
      }
      def mapping
        @mapping ||= DEFAULT_MAPPING.deep_dup
      end

      def mapping=(custom_mapping)
        mapping.deep_merge!(custom_mapping.deep_dup)
      end

      def update_mapping(index_name = alias_name)
        connection.json_put "/#{index_name}/_mapping?include_type_name=false", mapping
      end

      def get_mapping(index_name = alias_name)
        json = connection.json_get "/#{index_name}/_mapping?include_type_name=false"

        unless json.empty?
          json.values.first['mappings']
        end
      end
    end
  end
end
