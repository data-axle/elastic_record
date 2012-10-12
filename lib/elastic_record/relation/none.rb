module ElasticRecord
  class Relation
    module None
      def to_a
        []
      end

      def count
        0
      end

      def facets
        {}
      end
      
      def as_elastic
        {}
      end
    end
  end
end