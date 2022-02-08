module ElasticRecord
  module AggregationResponse
    class Builder
      AGGREGATION_KLASSES = {
        SingleBucketAggregation => %w(
          children
          sampler
          filter
          missing
          nested
          reverse_nested
          global
        ),
        MultiBucketAggregation => %w(
          composite
          date_histogram
          filters
          geohash_grid
          histogram
          range
          dterms
          lterms
          sterms
        ),
        SingleValueAggregation => %w(
          avg
          cardinality
          max
          min
          sum
          value_count
        ),
        MultiValueAggregation => %w(
          stats
          dpercentiles
          lpercentiles
          spercentiles
        )
      }

      AGGREGATIONS_BY_TYPE = AGGREGATION_KLASSES.each_with_object({}) do |(klass, types), hash|
        types.each { |type| hash[type] = klass }
      end

      def self.extract(hash)
        hash.each_with_object({}) do |(key, results), aggs|
          next unless key.include?('#')

          type, name = key.split('#')
          klass = AGGREGATIONS_BY_TYPE.fetch(type)
          aggs[name] = klass.new(name, results)
        end
      end
    end
  end
end
