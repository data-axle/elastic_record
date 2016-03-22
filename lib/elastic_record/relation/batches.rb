module ElasticRecord
  class Relation
    class ScanSearch
      attr_reader :scroll_id
      attr_accessor :total_hits

      def initialize(model, scroll_id, options = {})
        @model     = model
        @scroll_id = scroll_id
        @options   = options
      end

      def request_more_ids
        json = @model.elastic_index.scroll(@scroll_id, keep_alive)
        json['hits']['hits'].map { |hit| hit['_id'] }
      end

      def keep_alive
        @options[:keep_alive] || (raise "Must provide a :keep_alive option")
      end

      def requested_batch_size
        @options[:batch_size]
      end
    end

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
        elastic_index.create_scan_search(options).each_slice(&block)
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end
    end
  end
end
