module ElasticRecord
  module SearchesMany
    class CollectionProxy < ElasticRecord::Relation
      def initialize(association)
        @association = association
        super association.klass, association.klass.arelastic
        merge! association.scope
      end

      def to_a
        @association.load_collection.reject(&:destroyed?)
      end

      def <<(*records)
        @association.concat(records) && self
      end
      alias_method :push, :<<
    end
  end
end