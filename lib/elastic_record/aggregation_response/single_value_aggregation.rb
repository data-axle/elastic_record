module ElasticRecord
  module AggregationResponse
    class SingleValueAggregation < Aggregation
      attr_accessor :value, :value_as_string
    end
  end
end
