module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, relation)
        if not exists? "#{percolator_name}"
          create "#{percolator_name}" 
        else
          update_mapping "#{percolator_name}" 
        end
        json_put "/_percolator/#{percolator_name}/#{name}", relation.as_elastic
      end

      def delete_percolator(name)
        json_delete "/_percolator/#{percolator_name}/#{name}"
      end

      def percolate_matches(record)
        # p json_get("/_percolator/#{alias_name}")
        json_get "/#{percolator_name}/#{type}/_percolate", 'doc' => record.as_search
      end
    end
  end
end