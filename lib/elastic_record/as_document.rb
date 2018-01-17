module ElasticRecord
  module AsDocument
    def as_search_document
      doctype.mapping[:properties].each_with_object({}) do |(field, mapping), result|
        value = elastic_search_value field, mapping

        unless value.nil?
          result[field] = value
        end
      end
    end

    def as_partial_update_document
      mappings = doctype.mapping[:properties]

      changed.each_with_object({}) do |field, result|
        if field_mapping = mappings[field]
          result[field] = elastic_search_value field, field_mapping
        end
      end
    end

    def elastic_search_value(field, mapping)
      value = try field
      return if value.nil?

      value = case mapping[:type].to_sym
              when :object
                value.try(:as_search_document) || value
              when :nested
                value.map(&:as_search_document)
              else
                value
              end

      if value.present? || value == false
        value
      end
    end
  end
end
