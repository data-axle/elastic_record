module ElasticRecord
  class Relation
    module Calculations
      # Retrieve a single aggregation:
      #
      # Widget.elastic_search.calculate(cardinality: {field: color'}).value
      # => 3
      def calculate(aggregation)
        agg_name = SecureRandom.hex(6)
        aggregate(agg_name => aggregation).aggregations[agg_name]
      end
    end
  end
end
