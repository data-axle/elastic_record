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
          date_histogram
          filters
          geohash_grid
          histogram
          range
          lterms
          sterms

        ),
        SingleValue => %w(
          avg
          cardinality
          max
          min
        ),
        MultiValue => %w(
          stats
          lpercentiles
          spercentiles
        )
      }

      AGGREGATIONS_BY_TYPE = AGGREGATION_KLASSES.each_with_object({}) do |(klass, types), hash|
        types.each { |type| hash[type] = klass }
      end

      def self.extract(hash)
        hash.each do |key, results|
          name, type = key.split('#')
          next if type.nil?

          klass = AGGREGATIONS_BY_TYPE.fetch(type)
          aggregations << klass.new(name, results)
        end.compact
      end
    end
  end
end
