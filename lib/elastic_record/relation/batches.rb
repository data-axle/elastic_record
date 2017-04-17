module ElasticRecord
  class Relation
    module Batches
      EACH_WITHOUT_LIMIT_WARNING = "#{self.name}#each should not be used without a limit.  Did you mean #find_each ?"
      def each(&block)
        ActiveSupport::Deprecation.warn EACH_WITHOUT_LIMIT_WARNING if self.limit_value.nil?
        super # Array
      end

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
        create_scan_search(options).each_slice(&block)
      end

      def create_scan_search(options)
        elastic_index.create_scan_search(as_elastic, options)
      end

      def reindex
        relation.find_in_batches do |batch|
          elastic_index.bulk_add(batch)
        end
      end
    end
  end
end
