require 'elastic_record/relation/search_methods'
require 'elastic_record/relation/delegation'

module ElasticRecord
  class Relation
    include ElasticRecord::Relation::SearchMethods
    include ElasticRecord::Relation::Delegation

    def count
      to_hits.total_entries
    end

    def facets
      to_hits.facets
    end

    def to_a
      to_hits.to_a
    end

    def to_hits
      search_client.search(as_elastic)
    end
  end
end