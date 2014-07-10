module ElasticRecord
  class Index
    module Warmer
      def create_warmer(name, elastic_query)
        connection.json_put "/#{alias_name}/#{type}/_warmer/#{name}", elastic_query
      end

      def delete_warmer(name)
        connection.json_delete "/#{alias_name}/#{type}/_warmer/#{name}"
      end

      def get_warmer(name)
        connection.json_get("/#{alias_name}/#{type}/_warmer/#{name}").values.first['warmers'][name]
      end

      def warmer_exists?(name)
        get_warmer(name)
        true
      rescue ElasticRecord::ConnectionError
        false
      end
    end
  end
end
