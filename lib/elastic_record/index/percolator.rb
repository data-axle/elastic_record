module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, elastic_query)
        # unless exists? percolator_name
        #   create percolator_name
        # end
        connection.json_put "/#{percolator_name}/.percolator/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/#{percolator_name}/.percolator/#{name}"
      end

      def percolator_exists?(name)
        connection.head("/#{percolator_name}/.percolator/#{name}") == '200'
      end

      def get_percolator(name)
        json = connection.json_get("/#{percolator_name}/.percolator/#{name}")
        json['_source'] if json['found']
      end

      def percolate(document)
        hits = connection.json_get("/#{percolator_name}/#{type}/_percolate", 'doc' => document)['matches']
        hits.map { |hits| hits['_id'] }
      end

      def all_percolators
        if hits = connection.json_get("/#{percolator_name}/.percolator/_search?q=*&size=500")['hits']
          hits['hits'].map { |hit| hit['_id'] }
        end
      end

      def create_percolator_index
        create(percolator_name) unless exists?(percolator_name)
      end

      def delete_percolator_index
        delete(percolator_name) if exists?(percolator_name)
      end

      def reset_percolators
        delete_percolator_index
        create_percolator_index
      end

      def percolator_name
        "#{alias_name}_percolator"
      end
    end
  end
end
