require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Documents
      def index_record(record, index_name: alias_name)
        unless disabled
          index_document(
            record.try(:id),
            record.as_search_document,
            index_name: index_name
          )
        end
      end

      def update_record(record, index_name: alias_name)
        unless disabled
          update_document(
            record.id,
            record.as_partial_update_document,
            index_name: index_name
          )
        end
      end

      def index_document(id, document, parent: nil, index_name: alias_name)
        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: mapping_type, _id: id }
          instructions[:parent] = parent if parent

          batch << { index: instructions }
          batch << document
        else
          path = "/#{index_name}/#{mapping_type}/#{id}"
          path << "?parent=#{parent}" if parent

          if id
            connection.json_put path, document
          else
            connection.json_post path, document
          end
        end
      end

      def update_document(id, document, parent: nil, index_name: alias_name)
        raise "Cannot update a document with empty id" if id.blank?
        params = {doc: document, doc_as_upsert: true}

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: mapping_type, _id: id, retry_on_conflict: 3 }
          instructions[:parent] = parent if parent

          batch << { update: instructions }
          batch << params
        else
          path = "/#{index_name}/#{mapping_type}/#{id}/_update?retry_on_conflict=3"
          path << "&parent=#{parent}" if parent

          connection.json_post path, params
        end
      end

      def delete_document(id, parent: nil, index_name: alias_name)
        raise "Cannot delete document with empty id" if id.blank?
        index_name ||= alias_name

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: mapping_type, _id: id, retry_on_conflict: 3 }
          instructions[:parent] = parent if parent
          batch << { delete: instructions }
        else
          path = "/#{index_name}/#{mapping_type}/#{id}"
          path << "&parent=#{parent}" if parent

          connection.json_delete path
        end
      end

      def delete_by_query(query)
        scroll_enumerator = build_scroll_enumerator search: query

        scroll_enumerator.each_slice do |hits|
          bulk do
            hits.each { |hit| delete_document hit['_id'] }
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

          yield

          if current_bulk_batch.any?
            body = current_bulk_batch.map { |action| "#{JSON.generate(action)}\n" }.join
            results = connection.json_post("/_bulk?#{options.to_query}", body)
            verify_bulk_results(results)
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
