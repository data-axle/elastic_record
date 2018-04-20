module ElasticRecord
  module AggregationResponse
    module HasAggregations
      def aggregations
        @aggregations ||= Builder.extract(results)
      end

      def multi_bucket_agg
        aggregations.values.map(&:multi_bucket_agg).compact.first
      end
    end
  end
end
