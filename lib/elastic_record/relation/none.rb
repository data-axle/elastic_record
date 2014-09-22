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

      def aggregations
        {}
      end

      def as_elastic
        Arelastic::Filters::Not.new(Arelastic::Queries::MatchAll.new).as_elastic
      end
    end
  end
end
