module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, relation)
        json_put "/_percolator/#{alias_name}/#{name}", relation.as_elastic
      end

      def delete_percolator(name)
        json_delete "/_percolator/#{alias_name}/#{name}"
      end

      def percolate_matches(record)
        # p json_get("/_percolator/#{alias_name}")
        json_get "/#{alias_name}/#{type}/_percolate", 'doc' => record.as_search
      end
    end
  end
end