require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    class ScrollSearch
      def initialize(elastic_index, elastic_query, options = {})
        @elastic_index  = elastic_index
        @elastic_query  = elastic_query
        @options        = options
        @latest_response  = nil
      end

      def each_slice(&block)
        while (hit_ids = request_more_ids).any?
          hit_ids.each_slice(batch_size, &block)
        end
      end

      def request_more_ids
        request_more_hits.map { |hit| hit['_id'] }
      end

      def request_more_hits
        request_next_scroll['hits']['hits']
      end

      def request_next_scroll
        if @latest_response.nil?
          @latest_response = initialize_search_response
        else
          @latest_response = @elastic_index.scroll(@latest_response['_scroll_id'], keep_alive)
        end
      end

      def total_hits
        initialize_search_response['hits']['total']
      end

      def initialize_search_response
        @initialize_search_response ||= begin
          search_options = {size: batch_size, scroll: keep_alive}
          elastic_query = @elastic_query.merge('sort' => '_doc')
          @elastic_index.search(elastic_query, search_options)
        end
      end

      def keep_alive
        @options[:keep_alive] || (raise "Must provide a :keep_alive option")
      end

      def batch_size
        @options[:batch_size] || (raise "Must provide a :batch_size option")
      end
    end

    module Documents
      def index_record(record, index_name: alias_name)
        unless disabled
          index_document(record.send(record.class.primary_key), record.as_search, index_name: index_name)
        end
      end

      def update_record(record, index_name: alias_name)
        unless disabled
          update_document(record.send(record.class.primary_key), record.as_partial_update_document, index_name: index_name)
        end
      end

      def index_document(id, document, parent: nil, index_name: alias_name)
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

      def update_document(id, document, parent: nil, index_name: alias_name)
        params = {doc: document, doc_as_upsert: true}

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: type, _id: id, _retry_on_conflict: 3 }
          instructions[:parent] = parent if parent

          batch << { update: instructions }
          batch << params
        else
          path = "/#{index_name}/#{type}/#{id}/_update?retry_on_conflict=3"
          path << "&parent=#{parent}" if parent

          connection.json_post path, params
        end
      end

      def delete_document(id,  parent: nil, index_name: alias_name)
        raise "Cannot delete document with empty id" if id.blank?
        index_name ||= alias_name

        if batch = current_bulk_batch
          instructions = { _index: index_name, _type: type, _id: id, _retry_on_conflict: 3 }
          instructions[:parent] = parent if parent
          batch << { delete: instructions }
        else
          path = "/#{index_name}/#{type}/#{id}"
          path << "&parent=#{parent}" if parent

          connection.json_delete path
        end
      end

      def delete_by_query(query)
        scroll_search = create_scroll_search query

        scroll_search.each_slice do |ids|
          bulk do
            ids.each { |id| delete_document(id) }
          end
        end
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

      def create_scroll_search(elastic_query, options = {})
        options[:batch_size] ||= 100
        options[:keep_alive] ||= ElasticRecord::Config.scroll_keep_alive

        ScrollSearch.new(self, elastic_query, options)
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

      def bulk_add(batch, index_name: alias_name)
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
