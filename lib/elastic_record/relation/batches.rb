module ElasticRecord
  class Relation
    module Batches
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each { |record| yield record }
        end
      end

      def find_in_batches(options = {})
        build_scroll_enumerator(options).each_slice do |hits|
          yield SearchHits.new(klass, hits).to_records
        end
      end

      def find_ids_in_batches(options = {})
        build_scroll_enumerator(options).each_slice do |hits|
          yield SearchHits.new(klass, hits).to_ids
        end
      end

      def build_scroll_enumerator(options)
        elastic_index.build_scroll_enumerator(search: as_elastic, **options)
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end
    end
  end
end
