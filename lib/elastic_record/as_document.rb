module ElasticRecord
  module AsDocument
    def as_search_document
      doctype.mapping[:properties].each_with_object({}) do |(field, mapping), result|
        value = value_for_elastic_search field, mapping

        unless value.nil?
          result[field] = value
        end
      end
    end

    def as_partial_update_document
      mappings = doctype.mapping[:properties]
      changed_fields = respond_to?(:saved_changes) ? saved_changes.keys : changed

      changed_fields.each_with_object({}) do |field, result|
        if field_mapping = mappings[field]
          result[field] = value_for_elastic_search field, field_mapping
        end
      end
    end

    def value_for_elastic_search(field, mapping)
      value = try field
      return if value.nil?

      value =
        case mapping[:type]&.to_sym
        when :object
          value_for_elastic_search_object(value)
        when :nested
          value.map { |entry| value_for_elastic_search_object(entry) }
        when :integer_range, :float_range, :long_range, :double_range, :date_range
          value_for_elastic_search_range(value)
        else
          value
        end

      if value.present? || value == false
        value
      end
    end

    def value_for_elastic_search_object(object)
      object.respond_to?(:as_search_document) ? object.as_search_document : object
    end

    def value_for_elastic_search_range(range)
      if range.begin <= range.end
        gte = range.begin unless range.begin == -Float::INFINITY
        lte = range.end unless range.end == Float::INFINITY

        {'gte' => gte, 'lte' => lte}
      end
    end
  end
end
