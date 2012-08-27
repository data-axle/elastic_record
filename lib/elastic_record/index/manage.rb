module ElasticRecord
  class Index
    module Manage
      def create(index_name = name)
        http.put(index_name, '')
        update_mapping
      end

      def delete(index_name = name)
        http.delete(index_name)
      end

      def exists?(index_name = name)
        http.head(index_name).code == '200'
      end

      def deploy(index_name)
        json = {
          actions: [
            {
              add: {
                "index" => index_name,
                "alias" => name
              }
            }
          ]
        }

        http.post('_aliases', ActiveSupport::JSON.encode(json))
      end

      def update_mapping(index_name = name)
        unless mapping.empty?
          model.elastic_connection.update_mapping(mapping, index: index_name)
        end
      end
    end
  end
end