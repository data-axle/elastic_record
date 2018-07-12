module ElasticRecord
  class Index
    module Mapping
      def update_mapping(index_name = alias_name)
        doctypes.each do |doctype|
          connection.json_put "/#{index_name}/_mapping/#{doctype.name}", doctype.mapping
        end
      end

      def get_mapping(index_name = alias_name)
        json = connection.json_get "/#{index_name}/_mapping"

        unless json.empty?
          json.values.first['mappings']
        end
      end
    end
  end
end
