require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Documents
      def index_record(record, index_name = nil)
        return if disabled

        index_name ||= alias_name
        document = record.respond_to?(:as_search) ? record.as_search : {}

        connection.json_put "/#{index_name}/#{type}/#{record.id}", document
      end
      
      def delete_record(record, index_name = nil)
        index_name ||= alias_name

        connection.json_delete "/#{index_name}/#{type}/#{record.id}"
      end

      def record_exists?(id)
        connection.json_get("/#{alias_name}/#{type}/#{id}")['exists']
      end

      def search(elastic_query, options = {})
        url = "/#{alias_name}/#{type}/_search"
        if options.any?
          url += "?#{options.to_query}"
        end

        connection.json_get url, elastic_query
      end

      def scroll(scroll_id, scroll_keep_alive)
        options = {scroll_id: scroll_id, scroll: scroll_keep_alive}
        connection.json_get("/_search/scroll?#{options.to_query}")
      end

      def bulk_add(batch, index_name = nil)
        return if disabled

        index_name ||= alias_name

        # connection.bulk do
          batch.each do |record|
            index_record(record, index_name)
          end
        # end
      end
    end
  end
end