require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/merging'
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
      to_hits.total_entries
    end

    def facets
      to_hits.facets
    end

    def create_percolator(name)
      klass.elastic_index.create_percolator(name, as_elastic)
    end

    def reset
      @hits = @records = nil
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
      to_hits.to_a.map(&:id)
    end

    def to_hits
      @hits ||= klass.elastic_connection.search(as_elastic)#, ids_only: true)
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
  end
end