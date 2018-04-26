module ElasticRecord
  module AggregationResponse
    class Aggregation
      attr_accessor :name, :results
      def initialize(name, results)
        @name     = name
        @results  = results
      end

      def meta
        results['meta']
      end

      def inspect
        "#<#{self.class} #{results}>"
      end
    end
  end
end
