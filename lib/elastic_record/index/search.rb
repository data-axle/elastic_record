require 'active_support/core_ext/object/to_query'

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

    module Search
      def record_exists?(id)
        get_doc(id)['found']
      end

      def search(elastic_query, options = {})
        url = "_search"
        url += "?#{options.to_query}" if options.any?

        get url, elastic_query
      end

      def multi_search(headers_and_bodies, options = {})
        url = "_msearch"
        url += "?#{options.to_query}" if options.any?

        queries = headers_and_bodies.flat_map { |header, body| [header.to_json, body.to_json] }
        queries = queries.join("\n") + "\n"
        get url, queries
      end

      def explain(id, elastic_query)
        get "_explain", elastic_query
      end

      def build_scroll_enumerator(search: nil, scroll_id: nil, batch_size: 100, keep_alive: ElasticRecord::Config.scroll_keep_alive)
        ScrollEnumerator.new(self, search: search, scroll_id: scroll_id, batch_size: batch_size, keep_alive: keep_alive)
      end

      def scroll(scroll_id, scroll_keep_alive)
        options = { scroll_id: scroll_id, scroll: scroll_keep_alive }
        connection.json_post("/_search/scroll", options)
      rescue ElasticRecord::ConnectionError => e
        case e.status_code
        when '400' then raise ElasticRecord::InvalidScrollError, e.message
        when '404' then raise ElasticRecord::ExpiredScrollError, e.message
        else raise e
        end
      end

      def delete_scroll(scroll_id)
        connection.json_delete('/_search/scroll', { scroll_id: scroll_id })
      end
    end
  end
end
