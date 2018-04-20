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
      end

      # # Override
      # def flatten_buckets
      #   multi_bucket_agg&.flattened_buckets || []
      # end

      def flatten_buckets
        if bucket_agg = multi_bucket_agg
          p "going in hard!"
          result = bucket_agg.buckets.inject([]) do |result, bucket|
            p "concating #{bucket.flatten_buckets}"
            result.concat bucket.flatten_buckets
          end
          p "result = #{result}"
          result
        else
          []
        end
      end

    end
  end
end
