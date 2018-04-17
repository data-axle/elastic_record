module ElasticRecord
  module AggregationResponse
    class MultiBucketAggregation < Aggregation
      include HasAggregations

      def buckets
        results['buckets']
      end
    end
  end
end
