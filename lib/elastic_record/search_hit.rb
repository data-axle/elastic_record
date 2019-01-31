module ElasticRecord
  module SearchHit
    def instantiate_from_hit(hit)
      attrs = parse_hit hit

      if respond_to?(:instantiate)
        instantiate(attrs)
      else
        self.new.tap do |record|
          attrs.each do |k, v|
            record.send("#{k}=", v) if record.respond_to?("#{k}=")
          end
        end
      end
    end

    private

      def parse_hit(hit)
        document = hit['_source'].merge('id' => hit['_id'])
        convert_ranges! document
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
          elastic_index.mapping[:properties].select do |_, definition|
            definition[:type].to_s.end_with? 'range'
          end
        end
      end
  end
end
