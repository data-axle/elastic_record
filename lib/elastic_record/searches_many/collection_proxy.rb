module ElasticRecord
  module SearchesMany
    class CollectionProxy < ElasticRecord::Relation
      def initialize(association)
        @association = association
        super association.klass
        merge! association.scope
      end

      def eager_loaded(records)
        @association.eager_loaded_collection(records)
      end

      def to_a
        records = @association.load_collection.reject(&:destroyed?)
        records = eager_load_associations(records) if eager_loading?
        records
      end

      def <<(*records)
        @association.concat(records) && self
      end
      alias_method :push, :<<
    end
  end
end
