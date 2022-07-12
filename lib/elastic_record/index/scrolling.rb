module ElasticRecord
  class Index
    module Scrolling
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
