module ElasticRecord
  class Index
    class ScrollEnumerator
      attr_reader :keep_alive, :batch_size, :scroll_id
      def initialize(elastic_index, search: nil, scroll_id: nil, keep_alive:, batch_size:)
        @elastic_index = elastic_index
        @search        = search
        @scroll_id     = scroll_id
        @keep_alive    = keep_alive
        @batch_size    = batch_size
      end

      def each_slice(&block)
        while (hits = request_more_hits.hits).any?
          hits.each_slice(batch_size, &block)
        end

        @elastic_index.delete_scroll(scroll_id)
      end

      def request_more_ids
        request_more_hits.to_ids
      end

      def request_more_hits
        SearchHits.from_response(request_next_scroll)
      end

      def request_next_scroll
        if scroll_id
          response = @elastic_index.scroll(scroll_id, keep_alive)

          if response['_scroll_id'] != scroll_id
            @elastic_index.delete_scroll(scroll_id)
          end
        else
          response = initial_search_response
        end

        @scroll_id =  response['_scroll_id']

        response
      end

      def total_hits
        SearchHits.from_response(initial_search_response).total
      end

      def initial_search_response
        @initial_search_response ||= begin
          search_options = { size: batch_size, scroll: keep_alive }
          elastic_query = @search.reverse_merge('sort' => '_doc')

          @elastic_index.search(elastic_query, search_options)
        end
      end
    end
  end
end
