module ElasticRecord
  class Relation
    module None
      def to_a
        []
      end

      def count
        0
      end

      def aggregations
        {}
      end

      def exists?(**conditions)
        false
      end

      def as_elastic
        Arelastic::Queries::MatchAll.new.negate.as_elastic
      end
    end
  end
end
