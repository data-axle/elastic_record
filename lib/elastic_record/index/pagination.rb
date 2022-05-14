module ElasticRecord
  class Index
    module Pagination
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

      def build_search_after(search: nil, point_in_time_id: nil, use_point_in_time: false, batch_size: 100, keep_alive: ElasticRecord::Config.scroll_keep_alive)
        SearchAfter.new(self,
          search:            search,
          point_in_time_id:  point_in_time_id,
          batch_size:        batch_size,
          keep_alive:        keep_alive,
          use_point_in_time: use_point_in_time
        )
      end

      def delete_point_in_time(point_in_time_id)
        connection.json_delete('/_pit', { id: point_in_time_id })
      end

      def create_point_in_time(keep_alive)
        connection.json_post("/#{alias_name}/_pit?keep_alive=#{keep_alive}")
      end

      def search_after(search:, keep_alive:, batch_size:, search_after: nil, point_in_time_id: nil)
        options = search_after_options(keep_alive, batch_size, search_after, point_in_time_id)
        elastic_query = search.merge(options).reverse_merge('sort' => '_doc')

        if point_in_time_id
          connection.json_get('/_search', elastic_query)
        else
          get '_search', elastic_query
        end
      end

      private

        def search_after_options(keep_alive, batch_size, search_after, point_in_time_id)
          search_options                = { size: batch_size }
          search_options[:pit]          = { id: point_in_time_id, keep_alive: keep_alive } if point_in_time_id
          search_options[:search_after] = search_after if search_after
          search_options
        end
    end
  end
end
