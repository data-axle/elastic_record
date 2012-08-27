module ElasticRecord
  class Index
    module Manage
      def create(index_name = name)
        model.elastic_connection.create_index(index_name)
        update_mapping
      end

      def delete(index_name = name)
        model.elastic_connection.delete_index(index_name)
      end

      def alias
        # alias_actions = {add: {index_name => pending_index_alias}}
        # elastic_connection.alias_index(alias_actions)
      end

      def update_mapping(index_name = name)
        unless mapping.empty?
          model.elastic_connection.update_mapping(mapping, index: index_name)
        end
      end
    end
  end
end