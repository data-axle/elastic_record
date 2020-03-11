module ElasticRecord
  module AsDocument
    def as_search_document(is_inner_object: false)
      elastic_index.mapping[:properties].each_with_object({}) do |(field, mapping), result|
        value = value_for_elastic_search field, mapping

        if (!value.nil? || is_inner_object)
          result[field] = value
        end
      end
    end

    def as_partial_update_document
      changed_fields = respond_to?(:saved_changes) ? saved_changes.keys : changed

      changed_fields.each_with_object({}) do |field, result|
        if mapping = elastic_index.mapping[:properties][field]
          result[field] = value_for_elastic_search(field, mapping)
        end
      end
    end

    def value_for_elastic_search(field, mapping)
      return if (value = try(field)).nil?

      case mapping[:type]&.to_sym
      when :object
        value_for_elastic_search_object(value, is_inner_object: true)
      when :nested
        return if value.empty?

        value.map { |entry| value_for_elastic_search_object(entry) }
      when :integer_range, :float_range, :long_range, :double_range, :date_range
        value_for_elastic_search_range(value)
      else
        value if value.present? || value == false
      end
    end

    def value_for_elastic_search_object(object, is_inner_object: nil)
      object.respond_to?(:as_search_document) ? object.as_search_document(is_inner_object: is_inner_object) : object
    end

    def value_for_elastic_search_range(range)
      gte = range.begin unless range.begin == -Float::INFINITY
      lte = range.end

      {'gte' => gte, 'lte' => lte}
    end
  end
end
