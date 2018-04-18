module ElasticRecord
  module AggregationResponse
    class SingleValueAggregation < Aggregation
      def value
        results['value']
      end
    end
  end
end
