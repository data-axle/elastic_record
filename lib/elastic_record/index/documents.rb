require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Documents
      def index_record(record, index_name: nil)
        return if disabled

        index_document(record.send(record.class.primary_key), record.as_search, index_name: index_name)
      end

      def update_record(record, index_name: nil)
        return if disabled

        update_document(record.send(record.class.primary_key), record.as_search, index_name: index_name)
      end

      def index_document(id, document, parent: nil, index_name: nil)
        return if disabled

        index_name ||= alias_name

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: type, _id: id }
          instructions[:parent] = parent if parent

          batch << { index: instructions }
          batch << document
        else
          path = "/#{index_name}/#{type}/#{id}"
          path << "?parent=#{parent}" if parent

          connection.json_put path, document
        end
      end

      def update_document(id, document, parent: nil, index_name: nil)
        return if disabled

        index_name ||= alias_name
        params = {doc: document, doc_as_upsert: true}

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: type, _id: id, _retry_on_conflict: 3 }
          instructions[:parent] = parent if parent

          batch << { update: instructions }
          batch << document
        else
          path = "/#{index_name}/#{type}/#{id}/_update"
          path << "?parent=#{parent}" if parent

          connection.json_post path, params
        end
      end

      def delete_document(id, index_name: nil)
        raise "Cannot delete document with empty id" if id.blank?
        index_name ||= alias_name

        if batch = current_bulk_batch
          batch << { delete: { _index: index_name, _type: type, _id: id } }
        else
          connection.json_delete "/#{index_name}/#{type}/#{id}"
        end
      end

      def delete_by_query(query)
        connection.json_delete "/#{alias_name}/#{type}/_query", query
      end

      def record_exists?(id)
        get(id)['found']
      end

      def search(elastic_query, options = {})
        url = "_search"
        if options.any?
          url += "?#{options.to_query}"
        end

        get url, elastic_query
      end

      def explain(id, elastic_query)
        get "_explain", elastic_query
      end

      def scroll(scroll_id, scroll_keep_alive)
        options = {scroll_id: scroll_id, scroll: scroll_keep_alive}
        connection.json_get("/_search/scroll?#{options.to_query}")
      end

      def bulk(options = {})
        connection.bulk_stack.push []

        yield

        if current_bulk_batch.any?
          body = current_bulk_batch.map { |action| "#{ElasticRecord::JSON.encode(action)}\n" }.join
          results = connection.json_post("/_bulk?#{options.to_query}", body)
          verify_bulk_results(results)
        end
      ensure
        connection.bulk_stack.pop
      end

      def bulk_add(batch, index_name: nil)
        index_name ||= alias_name

        bulk do
          batch.each do |record|
            index_record(record, index_name: index_name)
          end
        end
      end

      def current_bulk_batch
        connection.bulk_stack.last
      end

      private

        def verify_bulk_results(results)
          return unless results.is_a?(Hash)

          errors = results['items'].select do |item|
            item.values.first['error']
          end

          raise ElasticRecord::BulkError.new(errors) unless errors.empty?
        end
    end
  end
end
