module ElasticRecord
  module Aggregations
    class MultiBucketAggregation < Aggregation
      include HasAggregations

      def buckets
        results['buckets']
      end
    end
  end
end
