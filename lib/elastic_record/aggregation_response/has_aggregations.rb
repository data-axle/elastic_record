module ElasticRecord
  module AggregationResponse
    module HasAggregations
      def aggregations
        @aggregations ||= Builder.extract(results)
      end

      def multi_bucket_agg
        aggregations.values.detect(&:multi_bucket_agg)
      end
    end
  end
end
