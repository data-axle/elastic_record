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
        hits.map { |hit| instantiate_from_hit(hit) }
      else
        model.find to_ids
      end
    end

    private

      def instantiate_from_hit(hit)
        attrs = hit['_source'].merge('id' => hit['_id'])

        if model.respond_to?(:instantiate)
          model.instantiate(attrs)
        else
          model.new.tap do |record|
            record.id = hit['_id']
            hit['_source'].each do |k, v|
              record.send("#{k}=", v) if record.respond_to?("#{k}=")
            end
          end
        end
      end
  end
end
