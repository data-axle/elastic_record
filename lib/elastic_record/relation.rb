require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/hits'
require 'elastic_record/relation/merging'
require 'elastic_record/relation/none'
require 'elastic_record/relation/search_methods'

module ElasticRecord
  class Relation
    include Batches, Delegation, FinderMethods, Hits, Merging, SearchMethods

    attr_reader :klass, :values

    def initialize(klass, values = {})
      @klass = klass
      @values = values
    end

    def count
      search_results['hits']['total']
    end

    def aggregations
      search_results['aggregations']
    end

    def krazy_aggregations
      ElasticRecord::Aggregations::Builder.extract(aggregations)
    end

    def explain(id)
      klass.elastic_index.explain(id, as_elastic)
    end

    def initialize_copy(other)
      @values = @values.dup
      reset
    end

    def to_a
      @records ||= load_hits(search_hits)
    end

    def delete_all
      find_ids_in_batches { |ids| klass.delete(ids) }
      klass.elastic_index.delete_by_query(as_elastic)
    end

    def ==(other)
      to_a == other
    end

    def inspect
      to_a.inspect
    end

    def scoping
      previous, klass.current_elastic_search = klass.current_elastic_search, self
      yield
    ensure
      klass.current_elastic_search = previous
    end

    private

      def reset
        @search_results = @records = nil
      end

  end
end
