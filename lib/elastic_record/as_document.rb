module ElasticRecord
  module AsDocument
    def as_search_document(mappings = doctype.mapping[:properties])
      (mappings || []).each_with_object({}) do |(field, mapping), result|
        nested = mappings.dig(field, :properties)
        value = value_for_elastic_search field, mapping, nested

        unless value.nil?
          result[field] = value
        end
      end
    end

    def as_partial_update_document
      mappings = doctype.mapping[:properties]
      changed_fields = respond_to?(:saved_changes) ? saved_changes.keys : changed

      changed_fields.each_with_object({}) do |field, result|
        nested = mappings.dig(field, :properties)
        if field_mapping = mappings[field]
          result[field] = value_for_elastic_search field, field_mapping, nested
        end
      end
    end

    def value_for_elastic_search(field, mapping, nested_mapping)
      value = try field
      return if value.nil?

      value =
        case mapping[:type]&.to_sym
        when :object
          value_for_elastic_search_object(value, nested_mapping)
        when :nested
          value.map { |entry| value_for_elastic_search_object(entry, nested_mapping) }
        when :integer_range, :float_range, :long_range, :double_range, :date_range
          value_for_elastic_search_range(value)
        else
          value
        end

      if value.present? || value == false
        value
      end
    end

    def value_for_elastic_search_object(object, nested_mapping)
      object.respond_to?(:as_search_document) ? object.as_search_document(nested_mapping) : object
    end

    def value_for_elastic_search_range(range)
      gte = range.begin unless range.begin == -Float::INFINITY
      lte = range.end unless range.end == Float::INFINITY

      {'gte' => gte, 'lte' => lte}
    end
  end
end
