module ElasticRecord
  class Index
    module Pagination
      def build_search_after(search: nil, point_in_time_id: nil, use_point_in_time: true, batch_size: 100, keep_alive: ElasticRecord::Config.scroll_keep_alive)
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
        payload = build_search_after_payload(search, keep_alive, batch_size, search_after, point_in_time_id)

        if point_in_time_id
          connection.json_get('/_search', payload)
        else
          get '_search', payload
        end
      rescue ConnectionError => e
        case e.status_code
        when '400' then raise InvalidPointInTimeError, e.message
        when '404' then raise ExpiredPointInTime, e.message
        else raise
        end
      end

      private

        def build_search_after_payload(search, keep_alive, batch_size, search_after, point_in_time_id)
          payload                = { size: batch_size }
          payload[:pit]          = { id: point_in_time_id, keep_alive: keep_alive } if point_in_time_id
          payload[:search_after] = search_after if search_after
          payload.merge!(search)
          payload['sort'] ||= Array.wrap(payload['sort'])
          payload['sort'] << '_shard_doc' unless payload['sort'].include?('_shard_doc')
          payload
        end
    end
  end
end
