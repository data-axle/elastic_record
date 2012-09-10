module ElasticRecord
  class Relation
    module Batches
      def find_each
        find_in_batches do |records|
          records.each { |record| yield record }
        end
      end

      def find_in_batches(options = {})
        scroll_keep_alive = '10m'

        options = {
          scroll: scroll_keep_alive,
          size: 100,
          search_type: 'scan'
        }

        scroll_id = klass.elastic_index.search(as_elastic, options)['_scroll_id']

        while (hit_ids = get_scroll_hit_ids(scroll_id, scroll_keep_alive)).any?
          yield klass.find(hit_ids)
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
