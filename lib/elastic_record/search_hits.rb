module ElasticRecord
  class SearchHits
    attr_accessor :hits, :model
    delegate(:[], *Enumerable.instance_methods, to: :hits)

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
        hits.map { |hit| load_from_hit(hit) }
      else
        model.find to_ids
      end
    end

    private

      def load_from_hit(hit)
        model.new.tap do |record|
          record.id = hit['_id']
          hit['_source'].each do |k, v|
            record.send("#{k}=", v) if record.respond_to?("#{k}=")
          end
        end
      end
  end
end
