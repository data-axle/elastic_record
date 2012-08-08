module ElasticRecord
  class Index
    module Manage
      def create(index_name = name)
        model.elastic_connection.create_index(index_name)
        # 
        # unless index_mapping.empty?
        #   elastic_connection.update_mapping(index_mapping, index: index_name)
        # end
      end

      def delete(index_name = name)
        model.elastic_connection.delete_index(index_name)
      end

      def alias
        # alias_actions = {add: {index_name => pending_index_alias}}
        # elastic_connection.alias_index(alias_actions)
      end
    end
  end
end