module ElasticRecord
  class Index
    module Mapping
      def update_mapping(index_name = alias_name)
        connection.json_put "/#{index_name}/_mapping/#{model.doctype.name}", mapping_body
      end

      def get_mapping(index_name = alias_name)
        json = connection.json_get "/#{index_name}/_mapping"

        unless json.empty?
          json.values.first['mappings']
        end
      end

      def mapping_body
        doctypes.each_with_object({}) do |doctype, result|
          result.deep_merge! doctype.mapping
        end
      end
    end
  end
end
