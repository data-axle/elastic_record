module ElasticRecord
  module AggregationResponse
    class SingleValueAggregation < Aggregation
      def value
        results['value']
      end

      def value_as_string
        results['value_as_string']
      end
    end
  end
end
