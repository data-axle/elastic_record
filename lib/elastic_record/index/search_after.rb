module ElasticRecord
  class Index
    class SearchAfter
      attr_reader :keep_alive, :batch_size, :point_in_time_id, :last_sort_values, :use_point_in_time
      def initialize(elastic_index, search: nil, point_in_time_id: nil, use_point_in_time: false, keep_alive:, batch_size:)
        @elastic_index     = elastic_index
        @search            = search
        @point_in_time_id  = point_in_time_id
        @use_point_in_time = use_point_in_time
        @keep_alive        = keep_alive
        @batch_size        = batch_size
      end

      def each_slice(&block)
        while (hits = request_more_hits.hits).any?
          hits.each_slice(batch_size, &block)
        end

        @elastic_index.delete_point_in_time(point_in_time_id) if point_in_time_id
      end

      def request_more_ids
        request_more_hits.to_ids
      end

      def request_more_hits
        SearchHits.from_response(request_next_page)
      end

      def request_next_page
        if @last_sort_values
          response = search_after

          if response['pit_id'] && response['pit_id'] != point_in_time_id
            @elastic_index.delete_point_in_time(point_in_time_id)
          end
        else
          if use_point_in_time && point_in_time_id.nil?
            refresh_point_in_time
          end

          response = initial_search_response
        end

        @point_in_time_id = response['pit_id']
        @last_sort_values =
          if last_hit = SearchHits.from_response(response).hits.last
            last_hit['sort']
          end

        response
      end

      def total_hits
        SearchHits.from_response(initial_search_response).total
      end

      def initial_search_response
        @initial_search_response ||= search_after
      end

      private

        def search_after
          @elastic_index.search_after(
            search:           @search,
            point_in_time_id: point_in_time_id,
            keep_alive:       keep_alive,
            batch_size:       batch_size,
            search_after:     @last_sort_values
          )
        end

        def refresh_point_in_time
          @point_in_time_id = @elastic_index.create_point_in_time(keep_alive)['id']
        end
    end
  end
end
