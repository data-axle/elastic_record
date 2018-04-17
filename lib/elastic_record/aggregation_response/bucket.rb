module ElasticRecord
  module AggregationResponse
    class SingleBucket < Aggregation
      include HasAggregations
      # key, doc_count
      def doc_count
        results['doc_count']
      end
    end
  end
end
