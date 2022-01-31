module ElasticRecord
  class Relation
    module Hits
      extend ActiveSupport::Concern

      def to_ids
        search_hits.to_ids
      end

      def search_hits
        SearchHits.from_response(search_results)
      end

      def search_results
        @search_results ||= begin
          options = { typed_keys: true, track_total_hits: true }
          options[:search_type] = search_type_value if search_type_value
          options[:_source] = if klass.elastic_index.load_from_source
            true
          elsif klass.respond_to?(:es_join_field)
            klass.es_join_field
          else
            false
          end

          klass.elastic_index.search(as_elastic, options)
        end
      end
    end
  end
end
