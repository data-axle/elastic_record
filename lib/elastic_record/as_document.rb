module ElasticRecord
  module AsDocument
    def as_search_document(mapping_properties = elastic_index.mapping[:properties])
      mapping_properties.each_with_object({}) do |(field, mapping), result|
        value = value_for_elastic_search field, mapping, mapping_properties

        unless value.nil?
          result[field] = value
        end
      end
    end

    def as_partial_update_document(mapping_properties = elastic_index.mapping[:properties])
      changed_fields = respond_to?(:saved_changes) ? saved_changes.keys : changed

      changed_fields.each_with_object({}) do |field, result|
        if field_mapping = mapping_properties[field]
          result[field] = value_for_elastic_search field, field_mapping, mapping_properties, true
        end
      end
    end

    def value_for_elastic_search(field, mapping, mapping_properties, is_update = false)
      return if (value = try(field)).nil?

      case mapping[:type]&.to_sym
      when :object
        object_mapping_properties = mapping_properties.dig(field, :properties)
        value_for_elastic_search_object(value, object_mapping_properties, is_update)
      when :nested
        return nil if value.empty?

        object_mapping_properties = mapping_properties.dig(field, :properties)
        value.map { |entry| value_for_elastic_search_object(entry, object_mapping_properties, false) }
      when :integer_range, :float_range, :long_range, :double_range, :date_range
        value_for_elastic_search_range(value)
      else
        value if value.present? || value == false
      end
    end

    def value_for_elastic_search_object(object, nested_mapping, is_update)
      method = is_update ? :as_partial_update_document : :as_search_document
      object.respond_to?(method) ? object.public_send(method, nested_mapping) : object
    end

    def value_for_elastic_search_range(range)
      gte = range.begin unless range.begin == -Float::INFINITY
      lte = range.end unless range.end == Float::INFINITY

      {'gte' => gte, 'lte' => lte}
    end
  end
end
