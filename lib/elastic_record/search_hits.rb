module ElasticRecord
  class SearchHits
    attr_accessor :hits, :model, :total

    class << self
      def from_response(response)
        new(response['hits']['hits'], total: response['hits']['total'])
      end
    end

    def initialize(hits, total: nil)
      @hits  = hits
      @total = total.is_a?(Hash) ? total['value'] : total
    end

    def to_ids
      hits.map { |hit| hit['_id'] }
    end
  end
end
