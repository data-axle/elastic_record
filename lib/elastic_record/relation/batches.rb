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

      def find_ids_in_batches(options = {})
        options.assert_valid_keys(:batch_size)

        scroll_keep_alive = '10m'
        size = options[:batch_size] || 100

        options = {
          scroll: scroll_keep_alive,
          size: size,
          search_type: 'scan'
        }.update(options)

        scroll_id = klass.elastic_index.search(as_elastic, options)['_scroll_id']

        while (hit_ids = get_scroll_hit_ids(scroll_id, scroll_keep_alive)).any?
          yield hit_ids
        end
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end

      private

        def get_scroll_hit_ids(scroll_id, scroll_keep_alive)
          json = klass.elastic_index.scroll(scroll_id, scroll_keep_alive)
          json['hits']['hits'].map { |hit| hit['_id'] }
        end
    end
  end
end
