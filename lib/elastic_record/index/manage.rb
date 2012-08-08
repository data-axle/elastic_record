module ElasticRecord
  class Index
    module Creation
      def create(index_name = search_index_name)
        # elastic_connection.create_index(index_name, index_creation_options)
        # 
        # unless index_mapping.empty?
        #   elastic_connection.update_mapping(index_mapping, index: index_name)
        # end
      end

      def delete
        # def delete_index!(index_name = search_index)
        #   elastic_connection.delete_index(index_name)
        # end
      end

      def alias
        # alias_actions = {add: {index_name => pending_index_alias}}
        # elastic_connection.alias_index(alias_actions)
      end
    end
  end
end