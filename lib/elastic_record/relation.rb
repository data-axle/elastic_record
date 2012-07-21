module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:extending, :filter, :facet, :order]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset]

    include Delegation, FinderMethods, SearchMethods

    attr_reader :klass, :arelastic

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

    def to_a
      @records ||= klass.find(to_ids)
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