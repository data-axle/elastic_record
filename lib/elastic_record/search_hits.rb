module ElasticRecord
  module SearchHits
    def map_hits_to_ids(hits)
      hits.map { |hit| hit['_id'] }
    end

    def hits_from_response(response)
      response['hits']['hits']
    end

    def load_hits(hits)
      if klass.elastic_index.load_from_source
        hits.map { |hit| load_from_hit(hit) }
      else
        klass.find map_hits_to_ids(hits)
      end
    end

    def load_from_hit(hit)
      klass.new.tap do |record|
        record.id = hit['_id']
        hit['_source'].each do |k, v|
          record.send("#{k}=", v) if record.respond_to?("#{k}=")
        end
      end
    end
  end
end
