module ElasticRecord
  module AggregationResponse
    class Aggregation
      attr_accessor :name, :results, :meta
      def initialize(name, results)
        @name     = name
        @results  = results

        @results.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def inspect
        "#<#{self.class} #{results}>"
      end
    end
  end
end
