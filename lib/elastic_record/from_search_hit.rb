module ElasticRecord
  module FromSearchHit

    def from_search_hit(hit, mapping_properties = elastic_index.mapping[:properties])
      hit = hit['_source'].merge('id' => hit['_id'])

      attrs = value_from_search_hit_object(hit, mapping_properties)

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

      def value_from_search_hit_object(hit, mapping_properties)
        mapping_properties.each_with_object(hit) do |(field, mapping), result|
          value = value_from_search_hit hit, field, mapping, mapping_properties

          unless value.nil?
            result[field] = value
          end
        end
      end

      def value_from_search_hit(hit, field, mapping, mapping_properties)
        value = hit[field]
        return if value.nil?

        value =
          case mapping[:type]&.to_sym
          when :object
            object_mapping_properties = mapping_properties.dig(field, :properties)
            value_from_search_hit_object(value, object_mapping_properties)
          when :nested
            object_mapping_properties = mapping_properties.dig(field, :properties)
            value.map { |entry| value_from_search_hit_object(entry, object_mapping_properties) }
          when :integer_range, :float_range, :long_range, :double_range
            value_for_range(value)
          when :date_range
            value_for_date_range(value)
          else
            value
          end

        if value.present? || value == false
          value
        end
      end

      def value_for_range(value)
        value['gte']..value['lte']
      end

      def value_for_date_range(value)
        Date.parse(value['gte'])..Date.parse(value['lte'])
      end
  end
end
