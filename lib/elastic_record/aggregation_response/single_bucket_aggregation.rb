module ElasticRecord
  module Aggregations
    class SingleBucketAggregation < Aggregation
      include HasAggregations

      def doc_count
        results['doc_count']
      end
    end
  end
end
