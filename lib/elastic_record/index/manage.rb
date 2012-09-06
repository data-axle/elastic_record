module ElasticRecord
  class Index
    module Manage
      def create_and_deploy(index_name = new_index_name)
        create(index_name)
        deploy(index_name)
        index_name
      end

      def create(index_name = new_index_name)
        json_put "/#{index_name}"
        update_mapping(index_name)
        index_name
      end

      def delete(index_name)
        json_delete "/#{index_name}"
      end

      def delete_all
        all_names.each do |index_name|
          delete index_name
        end
      end

      def exists?(index_name)
        head("/#{index_name}") == '200'
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

        aliased_names.each do |index_to_remove|
          actions << {
            remove: {
              "index" => index_to_remove,
              "alias" => alias_name
            }
          }
        end

        json_post '/_aliases', actions: actions
      end

      def update_mapping(index_name)
        json_put "/#{index_name}/#{type}/_mapping", type => mapping
      end

      def refresh
        connection.refresh
      end

      def reset
        delete_all
        create_and_deploy
      end

      def aliased_names
        json = json_get '/_cluster/state'
        json["metadata"]["indices"].select { |name, status| status["aliases"].include?(alias_name) }.map { |name, status| name }
      end

      def all_names
        json = json_get '/_status'

        regex = %r{^#{alias_name}_?}
        json['indices'].keys.grep(regex)
      end
    end
  end
end