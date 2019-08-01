module ElasticRecord
  class SearchHits
    attr_accessor :hits, :model, :count

    class << self
      def from_response(response)
        new(hits: response['hits']['hits'], total: response['hits']['total'])
      end
    end

    def initialize(hits:, total: nil)
      @hits  = hits
      @count = total.is_a?(Hash) ? total['value'] : total
    end

    def to_ids
      hits.map { |hit| hit['_id'] }
    end
  end
end
