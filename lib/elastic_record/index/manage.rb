module ElasticRecord
  class Index
    module Manage
      def create_and_deploy(index_name = new_index_name)
        create(index_name)
        deploy(index_name)
        index_name
      end

      def create(index_name = new_index_name)
        connection.json_put "/#{index_name}", "settings" => settings
        update_mapping(index_name)
        index_name
      end

      def delete(index_name)
        connection.json_delete "/#{index_name}"
      end

      def delete_all
        all_names.each do |index_name|
          delete index_name
        end
      end

      def open(index_name)
        connection.json_post("/#{index_name}/_open")
      end

      def close(index_name)
        connection.json_post("/#{index_name}/_close")
      end

      def exists?(index_name)
        connection.head("/#{index_name}") == '200'
      end

      def type_exists?(index_name = alias_name)
        connection.head("/#{index_name}/#{type}") == '200'
      end

      def deploy(index_name)
        actions = [
          {
            add: {
              "index" => index_name,
              "alias" => alias_name
            }
          }
        ]

        (aliased_names - [index_name]).each do |index_to_remove|
          actions << {
            remove: {
              "index" => index_to_remove,
              "alias" => alias_name
            }
          }
        end

        connection.json_post '/_aliases', actions: actions
      end

      def refresh(index_name = alias_name)
        connection.json_post "/#{index_name}/_refresh"
      end

      def reset
        delete_all
        create_and_deploy
      end

      def aliased_names
        json = connection.json_get "/#{all_names.join(',')}/_alias"
        json.keys.select do |index_name|
          json[index_name]['aliases'].keys.include?(alias_name)
        end
      end

      def all_names
        connection.json_get("/_mapping/#{type}/").keys
      end
    end
  end
end
