module ElasticRecord
  module Aggregations
    module HasAggregations
      def aggregations
        @aggregations ||= Builder.extract(results)
      end
    end
  end
end
