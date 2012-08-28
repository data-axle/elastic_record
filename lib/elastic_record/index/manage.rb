module ElasticRecord
  class Index
    module Manage
      def create(suffix = new_suffix)
        index_name = alias_and_suffix(suffix)

        http.put(index_name, '')
        update_mapping(suffix)
      end

      def delete(suffix)
        index_name = alias_and_suffix(suffix)

        http.delete(index_name)
      end

      def exists?(suffix)
        index_name = alias_and_suffix(suffix)

        http.head(index_name).code == '200'
      end

      def deploy(suffix)
        index_name = alias_and_suffix(suffix)

        actions = [
          {
            add: {
              "index" => index_name,
              "alias" => alias_name
            }
          }
        ]

        if index_to_remove = deployed_name
          actions << {
            remove: {
              "index" => index_to_remove,
              "alias" => alias_name
            }
          }
        end

        http.post('_aliases', ActiveSupport::JSON.encode(actions: actions))
      end

      def update_mapping(suffix)
        index_name = alias_and_suffix(suffix)

        unless mapping.empty?
          connection.update_mapping(mapping, index: index_name)
        end
      end

      def deployed_name
        deployed_index, _ = connection.cluster_state["metadata"]["indices"].detect { |name, status| status["aliases"].include?(alias_name) }
        deployed_index
      end

      def all_suffixes
        json = ActiveSupport::JSON.decode http.get('_status').body

        regex = %r{^#{alias_name}_}
        json['indices'].keys.grep(regex).map { |index_name| index_name.gsub(regex, '') }
      end

      private
        def alias_and_suffix(suffix)
          "#{alias_name}_#{suffix}"
        end

        def new_suffix
          Time.now.to_i
        end
    end
  end
end