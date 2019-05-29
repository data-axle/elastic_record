module ElasticRecord
  class SearchHits
    attr_accessor :hits, :model

    class << self
      def from_response(response)
        new(response['hits']['hits'])
      end
    end

    def initialize(hits)
      @hits  = hits
    end

    def to_ids
      hits.map { |hit| hit['_id'] }
    end
  end
end
