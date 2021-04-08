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
        Rails.logger.info "ELASTIC_RECORD: called updating_mapping #{index_name}"
        Rails.logger.info "#{mapping}"
        connection.json_put "/#{index_name}/_mapping", mapping
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
