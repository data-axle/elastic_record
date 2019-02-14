module ElasticRecord
  module FromSearchHit

    def from_search_hit(hit)
      hit = hit['_source'].merge('id' => hit['_id'])

      attrs = value_from_search_hit_object(hit)

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

      def value_from_search_hit_object(hit)
        hit.each do |field, value|
          next unless value

          case value
          when Hash
            hit[field] = value_from_search_hit(value)
          when Array
            hit[field] = value.map { |el| value_from_search_hit_object(el) }
          end
        end

        hit
      end

      RANGE_KEYS = %w(gte lte)
      def value_from_search_hit(value)
        if (RANGE_KEYS & value.keys).any?
          value = case value['lte'] # Lower bound is never nil
          when String
            value_for_date_range(value)
          when Integer
            value_for_range(value)
          end
        else
          case value
          when Hash
            value_from_search_hit_object(value)
          end
        end
        value
      end

      def value_for_range(value)
        value['gte'] = -Float::INFINITY if value['gte'].nil?
        value['lte'] =  Float::INFINITY if value['lte'].nil?
        value['gte']..value['lte']
      end

      def value_for_date_range(value)
        Date.parse(value['gte'])..Date.parse(value['lte'])
      end
  end
end
