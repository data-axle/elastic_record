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
        attrs = parse_hit hit

        if model.respond_to?(:instantiate)
          model.instantiate(attrs)
        else
          model.new.tap do |record|
            attrs.each do |k, v|
              record.send("#{k}=", v) if record.respond_to?("#{k}=")
            end
          end
        end
      end

      def parse_hit(hit)
        attrs = hit['_source'].merge('id' => hit['_id'])
        convert_ranges! attrs
      end

      def convert_ranges!(document)
        range_fields.each do |datatype, definition|
          next unless document[datatype]

          range = document[datatype]['gte']..document[datatype]['lte']

          if definition[:type].to_s == 'date_range'
            range = Date.parse(range.begin)..Date.parse(range.end)
          end

          document[datatype] = range
        end

        document
      end

      def range_fields
        @range_fields ||= begin
          model.elastic_index.mapping[:properties].select do |_, definition|
            definition[:type].to_s.end_with? 'range'
          end
        end
      end
  end
end
