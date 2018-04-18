module ElasticRecord
  module AggregationResponse
    class SingleBucketAggregation < Aggregation
      include HasAggregations

      def doc_count
        results['doc_count']
      end
    end
  end
end
