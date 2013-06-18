module ElasticRecord
  class Relation
    module Batches
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each { |record| yield record }
        end
      end

      def find_in_batches(options = {})
        find_ids_in_batches(options) do |ids|
          yield klass.find(ids)
        end
      end

      def find_ids_in_batches(options = {}, &block)
        options.assert_valid_keys(:batch_size, :keep_alive)

        scroll_keep_alive = options[:keep_alive] || ElasticRecord::Config.scroll_keep_alive
        size = options[:batch_size] || 100

        options = {
          scroll: scroll_keep_alive,
          size: size,
          search_type: 'scan'
        }.update(options)

        search_result = klass.elastic_index.search(as_elastic, options)
        total_hits = search_result['hits']['total']
        scroll_id = search_result['_scroll_id']
        hit_count = 0

        while (hit_ids = get_scroll_hit_ids(scroll_id, scroll_keep_alive, (hit_count < total_hits))).any?
          hit_count += hit_ids.size
          hit_ids.each_slice(size, &block)
        end
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end

      private

        def get_scroll_hit_ids(scroll_id, scroll_keep_alive, exception_detection)
          json = klass.elastic_index.scroll(scroll_id, scroll_keep_alive)
          if exception_detection && json['_shards'] && json['_shards']['failed'] > 0
            raise ScrollKeepAliveError.new(json.to_s)
          end
          json['hits']['hits'].map { |hit| hit['_id'] }
        end
    end
  end
end
