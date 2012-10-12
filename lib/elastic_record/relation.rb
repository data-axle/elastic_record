require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/merging'
require 'elastic_record/relation/none'
require 'elastic_record/relation/search_methods'

module ElasticRecord
  class Relation
    include Batches, Delegation, FinderMethods, Merging, SearchMethods

    attr_reader :klass, :arelastic, :values

    def initialize(klass, arelastic)
      @klass = klass
      @arelastic = arelastic
      @values = {}
    end

    def count
      search_results['hits']['total']
    end

    def facets
      search_results['facets']
    end

    def create_percolator(name)
      klass.elastic_index.create_percolator(name, as_elastic)
    end

    def explain(id)
      klass.elastic_index.explain(id, as_elastic)
    end

    def initialize_copy(other)
      @values = @values.dup
      reset
    end

    def to_a
      @records ||= begin
        scope = select_values.any? ? klass.select(select_values) : klass
        scope.find(to_ids)
      end
    end

    def to_ids
      search_hits.map { |hit| hit['_id'] }
    end

    def ==(other)
      case other
      when Relation
        other.as_elastic == as_elastic
      when Array
        to_a == other
      end
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
    
      def search_hits
        search_results['hits']['hits']
      end

      def search_results
        @search_results ||= klass.elastic_index.search(as_elastic)
      end
  end
end