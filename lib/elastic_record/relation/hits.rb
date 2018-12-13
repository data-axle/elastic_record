require 'elastic_record/search_hits'

module ElasticRecord
  class Relation
    module Hits
      include ElasticRecord::SearchHits

      def to_ids
        map_hits_to_ids search_hits
      end

      def search_hits
        hits_from_response(search_results)
      end

      def search_results
        @search_results ||= begin
          options = {typed_keys: true}
          options[:search_type] = search_type_value if search_type_value

          klass.elastic_index.search(as_elastic, options)
        end
      end
    end
  end
end
