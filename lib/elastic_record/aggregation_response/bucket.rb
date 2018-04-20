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

      def flatten_buckets
        if multi_bucket_agg
          multi_bucket_agg.flatten_buckets.map do |flattened|
            [self] + flattened
          end
        else
          [[self]]
        end
      end

      # "<#{self.class} #{@parameters} permitted: #{@permitted}>"
    end
  end
end
