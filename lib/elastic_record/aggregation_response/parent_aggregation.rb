module ElasticRecord
  module AggregationResponse
    class ParentAggregation < Aggregation
      include HasAggregations

      def wrapped_aggregation
        @wrapped_aggregation ||= aggregations.fetch(name)
      end

      def buckets
        if wrapped_aggregation.is_a?(MultiBucketAggregation)
          wrapped_aggregation.buckets
        else
          raise "Not valid for '#{inspect}'"
        end
      end

      def value
        if wrapped_aggregation.is_a?(SingleValueAggregation)
          wrapped_aggregation.value
        else
          raise "Not valid for '#{inspect}'"
        end
      end

      def doc_count
        case wrapped_aggregation
        when SingleBucketAggregation then wrapped_aggregation.doc_count
        when MultiBucketAggregation  then wrapped_aggregation.results.fetch('doc_count')
        when SingleValueAggregation  then results.fetch('doc_count')
        else raise "Not valid for '#{inspect}'"
        end
      end
    end
  end
end
