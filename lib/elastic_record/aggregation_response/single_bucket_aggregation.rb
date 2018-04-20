module ElasticRecord
  module AggregationResponse
    class SingleBucketAggregation < Aggregation
      include HasAggregations
      attr_accessor :doc_count
    end
  end
end
