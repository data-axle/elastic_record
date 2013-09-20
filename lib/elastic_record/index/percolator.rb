module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, elastic_query)
        connection.json_put "/_percolator/#{percolator_index_name}/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/_percolator/#{percolator_index_name}/#{name}"
      end

      def percolator_exists?(name)
        !get_percolator(name).nil?
      end

      def get_percolator(name)
        json = connection.json_get("/_percolator/#{percolator_index_name}/#{name}")
        json['_source'] if json['exists']
      end

      def percolate(document)
        connection.json_get("/#{percolator_index_name}/#{type}/_percolate", 'doc' => document)['matches']
      end

      def all_percolators
        if hits = connection.json_get("/_percolator/#{percolator_index_name}/_search?q=*&size=500")['hits']
          hits['hits'].map { |hit| hit['_id'] }
        end
      end

      def reset_percolator
        delete(percolator_index_name) if exists?(percolator_index_name)
        create(percolator_index_name)
      end

      def percolator_index_name
        alias_name
        # @percolator_index_name ||= "percolate_#{alias_name}"
      end
    end
  end
end
