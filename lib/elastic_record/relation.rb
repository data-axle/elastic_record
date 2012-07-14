module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:filter, :facet, :sort]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset]

    include Delegation, SearchMethods

    attr_reader :klass

    def initialize(klass)
      @klass = klass
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
      to_hits.to_a
    end

    def to_hits
      @hits ||= search_client.search(as_elastic)
    end

    def scoping
      previous, klass.current_scope = klass.current_scope, self
      yield
    ensure
      klass.current_scope = previous
    end
  end
end