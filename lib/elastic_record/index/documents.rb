require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Documents
      def index_record(record, index_name: alias_name)
        unless disabled
          index_document(
            record.try(:id),
            record.as_search_document,
            routing: record.try(:routing),
            index_name: index_name
          )
        end
      end

      def update_record(record, index_name: alias_name)
        unless disabled
          update_document(
            record.id,
            record.as_partial_update_document,
            routing: record.try(:routing),
            index_name: index_name
          )
        end
      end

      def index_document(id, document, routing: nil, index_name: alias_name)
        if batch = current_bulk_batch
          instructions = { _index: index_name, _id: id }
          instructions[:routing] = routing if routing

          batch << { index: instructions }
          batch << document
        else
          path = "/#{index_name}/_doc/#{id}"
          path << "?routing=#{routing}" if routing

          if id
            connection.json_put path, document
          else
            connection.json_post path, document
          end
        end
      end

      def update_document(id, document, routing: nil, index_name: alias_name)
        raise "Cannot update a document with empty id" if id.blank?
        params = {doc: document, doc_as_upsert: true}

        if batch = current_bulk_batch
          instructions = { _index: index_name, _id: id, retry_on_conflict: 3 }
          instructions[:routing] = routing if routing

          batch << { update: instructions }
          batch << params
        else
          path = "/#{index_name}/_update/#{id}?retry_on_conflict=3"
          path << "&routing=#{routing}" if routing

          connection.json_post path, params
        end
      end

      def delete_document(id, routing: nil, index_name: alias_name)
        raise "Cannot delete document with empty id" if id.blank?

        if batch = current_bulk_batch
          instructions = { _index: index_name, _id: id, retry_on_conflict: 3 }
          instructions[:routing] = routing if routing
          batch << { delete: instructions }
        else
          path = "/#{index_name}/_doc/#{id}"
          path << "?routing=#{routing}" if routing

          connection.json_delete path
        end
      end

      def delete_by_query(query)
        scroll_enumerator = build_scroll_enumerator search: query

        scroll_enumerator.each_slice do |hits|
          bulk do
            hits.each do |hit|
              delete_document hit['_id'], routing: hit['_routing']
            end
          end
        end
      end

      def bulk(options = {}, &block)
        if current_bulk_batch
          yield
        else
          start_new_bulk_batch(options, &block)
        end
      end

      def bulk_add(batch, index_name: alias_name)
        bulk do
          batch.each do |record|
            index_record(record, index_name: index_name)
          end
        end
      end

      def current_bulk_batch
        connection.bulk_actions
      end

      private

        def start_new_bulk_batch(options, &block)
          connection.bulk_actions = []

          yield.tap do
            if current_bulk_batch.any?
              body = current_bulk_batch.map { |action| "#{ActiveSupport::JSON.encode(action)}\n" }.join
              results = connection.json_post("/_bulk?#{options.to_query}", body)
              verify_bulk_results(results)
            end
          end
        ensure
          connection.bulk_actions = nil
        end

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
