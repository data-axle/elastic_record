module ElasticRecord
  module AggregationResponse
    class ParentAggregation < Aggregation
      include HasAggregations

      def initialize(*)
        super

        if wrapped_aggregation.is_a?(MultiBucketAggregation)
          singleton_class.delegate :buckets, to: :wrapped_aggregation
          define_singleton_method(:doc_count) do
            wrapped_aggregation.results.fetch('doc_count')
          end
        end

        if wrapped_aggregation.is_a?(SingleBucketAggregation)
          singleton_class.delegate :doc_count, to: :wrapped_aggregation
        end

        if wrapped_aggregation.is_a?(SingleValueAggregation)
          singleton_class.delegate :value, to: :wrapped_aggregation
          define_singleton_method(:doc_count) do
            results.fetch('doc_count')
          end
        end
      end

      def wrapped_aggregation
        @wrapped_aggregation ||= aggregations.fetch(name)
      end
    end
  end
end
