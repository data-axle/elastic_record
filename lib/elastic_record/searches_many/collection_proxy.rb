module ElasticRecord
  module SearchesMany
    class CollectionProxy < ElasticRecord::Relation
      def initialize(association)
        @association = association
        super association.klass, association.klass.arelastic
        merge! association.scope
      end

      def eager_loaded(records)
        @association.eager_loaded_collection(records)
      end

      def to_a
        if @association.loaded? || !eager_loading?
          @association.load_collection.reject(&:destroyed?)
        else
          records = @association.load_collection.reject(&:destroyed?)
          eager_load_associations(records)
        end
      end

      def <<(*records)
        @association.concat(records) && self
      end
      alias_method :push, :<<
    end
  end
end
