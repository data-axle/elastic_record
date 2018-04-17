module ElasticRecord
  module AggregationResponse
    class Bucket
      include HasAggregations

      attr_accessor :results
      def initialize(results)
        @results = results
      end

      def key
        results['key']
      end

      def doc_count
        results['doc_count']
      end
    end
  end
end
