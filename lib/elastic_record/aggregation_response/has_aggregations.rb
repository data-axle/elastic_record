module ElasticRecord
  module AggregationResponse
    module HasAggregations
      def aggregations
        @aggregations ||= Builder.extract(results)
      end
    end
  end
end
