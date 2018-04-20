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

      # Override
      def multi_bucket_agg
        nil
      end

      def flatten_buckets
        if bucket_agg = multi_bucket_agg
          bucket_agg.buckets.inject([]) do |result, bucket|
            result.concat bucket.flatten_buckets
          end
        else
          []
        end
      end

    end
  end
end
