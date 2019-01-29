module ElasticRecord
  class SearchHits
    attr_accessor :hits, :model

    class << self
      def from_response(model, response)
        new(model, response['hits']['hits'])
      end
    end

    def initialize(model, hits)
      @model = model
      @hits  = hits
    end

    def to_ids
      hits.map { |hit| hit['_id'] }
    end

    def to_records
      if model.elastic_index.load_from_source
        hits.map { |hit| model.instantiate(hit) }
      else
        model.find to_ids
      end
    end
  end
end
