module ElasticRecord
  module AggregationResponse
    class SingleBucketAggregation < Aggregation
      include HasAggregations

      def doc_count
        results['doc_count']
      end
    end
  end
end

# smash concep
# SingleBucketAggregation
#
# def smash
#   if aggregations.any?
#.    { one/many }
#   else
#     doc_count
#   end
# end
#

# MultiBucketAggregation
#
# def smash
#   if aggregations.any?
#.    { one/many }
#   else
#     buckets....
#     doc_count
#   end
# end
#
