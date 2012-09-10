require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Documents
      def index_document(id, document, index_name = nil)
        return if disabled

        index_name ||= alias_name

        if @batch
          @batch << { index: { _index: index_name, _type: type, _id: id } }
          @batch << document
        else
          connection.json_put "/#{index_name}/#{type}/#{id}", document
        end
      end
      
      def delete_document(id, index_name = nil)
        index_name ||= alias_name

        if @batch
          @batch << { delete: { _index: index_name, _type: type, _id: id } }
        else
          connection.json_delete "/#{index_name}/#{type}/#{id}"
        end
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

        bulk do
          batch.each do |record|
            index_document(record.id, record.as_search, index_name)
          end
        end
      end

      def bulk
        @batch = []
        yield
        if @batch.any?
          body = @batch.map { |action| "#{ActiveSupport::JSON.encode(action)}\n" }.join
          connection.json_post "/_bulk", body
        end
      ensure
        @batch = nil
      end
    end
  end
end