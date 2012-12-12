module ElasticRecord
  class Index
    module Manage
      def create_and_deploy(index_name = new_index_name)
        create(index_name)
        deploy(index_name)
        index_name
      end

      def create(index_name = new_index_name)
        connection.json_put "/#{index_name}"
        update_mapping(index_name)
        update_settings(index_name)
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

      def exists?(index_name)
        connection.head("/#{index_name}") == '200'
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

      def update_mapping(index_name = alias_name)
        connection.json_put "/#{index_name}/#{type}/_mapping", type => mapping
      end

      def update_settings(index_name = alias_name)
        connection.json_put "/#{index_name}/_settings", settings
      end

      def refresh(index_name = alias_name)
        connection.json_post "/#{index_name}/_refresh"
      end

      def reset
        delete_all
        create_and_deploy
      end

      def aliased_names
        json = connection.json_get '/_cluster/state'
        json["metadata"]["indices"].select { |name, status| status["aliases"].include?(alias_name) }.map { |name, status| name }
      end

      def all_names
        json = connection.json_get '/_status'

        regex = %r{^#{alias_name}_?}
        json['indices'].keys.grep(regex)
      end
    end
  end
end