module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, elastic_query)
        p "elastic_query = #{elastic_query}"
        connection.json_put "/#{alias_name}/.percolator/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/#{alias_name}/.percolator/#{name}"
      end

      def percolator_exists?(name)
        connection.head("/#{alias_name}/.percolator/#{name}") == '200'
      end

      def get_percolator(name)
        json = connection.json_get("/#{alias_name}/.percolator/#{name}")
        json['_source'] if json['exists']
      end

      def percolate(document)
        connection.json_get("/#{alias_name}/#{type}/_percolate", 'doc' => document)['matches']
      end

      def all_percolators
        if hits = connection.json_get("/#{alias_name}/.percolator/_search?q=*&size=500")['hits']
          hits['hits'].map { |hit| hit['_id'] }
        end
      end

      # def reset_percolator
      #   delete(percolator_index_name) if exists?(percolator_index_name)
      #   create(percolator_index_name)
      # end
    end
  end
end
