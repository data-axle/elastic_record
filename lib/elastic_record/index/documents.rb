require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    class ScrollEnumerator
      attr_reader :keep_alive, :batch_size, :scroll_id
      def initialize(elastic_index, search: nil, scroll_id: nil, keep_alive:, batch_size:)
        @elastic_index  = elastic_index
        @search         = search
        @scroll_id      = scroll_id
        @keep_alive     = keep_alive
        @batch_size     = batch_size
      end

      def each_slice(&block)
        while (hits = request_more_hits).any?
          hits.each_slice(batch_size, &block)
        end
      end

      def request_more_ids
        request_more_hits.map { |hit| hit['_id'] }
      end

      def request_more_hits
        request_next_scroll['hits']['hits']
      end

      def request_next_scroll
        if scroll_id.nil?
          response = initial_search_response
        else
          response = @elastic_index.scroll(scroll_id, keep_alive)
        end

        @scroll_id = response['_scroll_id']
        response
      end

      def total_hits
        initial_search_response['hits']['total']
      end

      def initial_search_response
        @initial_search_response ||= begin
          search_options = {size: batch_size, scroll: keep_alive}
          elastic_query = @search.reverse_merge('sort' => '_doc')

          @elastic_index.search(elastic_query, search_options)
        end
      end
    end

    module Documents
      def index_record(record, index_name: alias_name)
        unless disabled
          index_document(
            record.try(:id),
            record.as_search_document,
            doctype: record.doctype,
            index_name: index_name
          )
        end
      end

      def update_record(record, index_name: alias_name)
        unless disabled
          update_document(
            record.id,
            record.as_partial_update_document,
            doctype: record.doctype,
            index_name: index_name
          )
        end
      end

      def index_document(id, document, doctype: model.doctype, parent: nil, index_name: alias_name)
        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: doctype.name, _id: id }
          instructions[:parent] = parent if parent

          batch << { index: instructions }
          batch << document
        else
          path = "/#{index_name}/#{doctype.name}/#{id}"
          path << "?parent=#{parent}" if parent

          if id
            connection.json_put path, document
          else
            connection.json_post path, document
          end
        end
      end

      def update_document(id, document, doctype: model.doctype, parent: nil, index_name: alias_name)
        raise "Cannot update a document with empty id" if id.blank?
        params = {doc: document, doc_as_upsert: true}

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: doctype.name, _id: id, retry_on_conflict: 3 }
          instructions[:parent] = parent if parent

          batch << { update: instructions }
          batch << params
        else
          path = "/#{index_name}/#{doctype.name}/#{id}/_update?retry_on_conflict=3"
          path << "&parent=#{parent}" if parent

          connection.json_post path, params
        end
      end

      def delete_document(id, doctype: model.doctype, parent: nil, index_name: alias_name)
        raise "Cannot delete document with empty id" if id.blank?
        index_name ||= alias_name

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: doctype.name, _id: id, retry_on_conflict: 3 }
          instructions[:parent] = parent if parent
          batch << { delete: instructions }
        else
          path = "/#{index_name}/#{doctype.name}/#{id}"
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

      def record_exists?(id)
        get(id, model.doctype)['found']
      end

      def search(elastic_query, options = {})
        url = "_search"
        if options.any?
          url += "?#{options.to_query}"
        end

        get url, model.doctype, elastic_query.update('_source' => load_from_source)
      end

      def explain(id, elastic_query)
        get "_explain", elastic_query
      end

      def build_scroll_enumerator(search: nil, scroll_id: nil, batch_size: 100, keep_alive: ElasticRecord::Config.scroll_keep_alive)
        ScrollEnumerator.new(self, search: search, scroll_id: scroll_id, batch_size: batch_size, keep_alive: keep_alive)
      end

      def scroll(scroll_id, scroll_keep_alive)
        options = {scroll_id: scroll_id, scroll: scroll_keep_alive}
        connection.json_get("/_search/scroll?#{options.to_query}")
      rescue ElasticRecord::ConnectionError => e
        case e.status_code
        when '400' then raise ElasticRecord::InvalidScrollError, e.message
        when '404' then raise ElasticRecord::ExpiredScrollError, e.message
        else raise e
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
