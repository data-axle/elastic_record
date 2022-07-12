module ElasticRecord
  class Relation
    module Batches
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each { |record| yield record }
        end
      end

      def find_in_batches(options = {})
        find_hits_in_batches(options) do |hits|
          yield find_hits(hits)
        end
      end

      def find_ids_in_batches(options = {})
        find_hits_in_batches(options) do |hits|
          yield hits.to_ids
        end
      end

      def find_hits_in_batches(options = {})
        build_paginator(options).each_slice do |hits|
          yield SearchHits.new(hits)
        end
      end

      def build_scroll_enumerator(options)
        elastic_index.build_scroll_enumerator(search: as_elastic, **options)
      end

      def build_search_after(options)
        elastic_index.build_search_after(search: as_elastic, **options)
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end

      private

        def build_paginator(options)
          if options.delete(:paginator) == :search_after
            build_search_after(options)
          else
            build_scroll_enumerator(options)
          end
        end
    end
  end
end
