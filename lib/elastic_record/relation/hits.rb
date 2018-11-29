module ElasticRecord
  class Relation
    module Hits
      def to_ids
        map_hits_to_ids search_hits
      end

      def load_hits(search_hits)
        if klass.elastic_index.load_from_source
           search_hits.map { |hit| load_from_hit(hit) }
        else
          klass.find map_hits_to_ids(search_hits)
        end
      end

      def map_hits_to_ids(hits)
        hits.map { |hit| hit['_id'] }
      end

      def search_hits
        search_results['hits']['hits']
      end

      def load_from_hit(hit)
        record = klass.new
        record.id = hit['_id']
        hit['_source'].each do |k, v|
          record.send("#{k}=", v) if record.respond_to?("#{k}=")
        end
        record
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
