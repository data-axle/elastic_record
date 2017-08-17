module ElasticRecord
  module AsSearch
    def as_search
      json = {}

      elastic_index.mapping[:properties].each do |field, mapping|
        value = elastic_search_value field, mapping

        unless value.nil?
          json[field] = value
        end
      end

      json
    end

    def as_partial_update_document
      json = {}

      mappings = elastic_index.mapping[:properties]
      changed.each do |field|
        if field_mapping = mappings[field]
          json[field] = elastic_search_value field, field_mapping
        end
      end

      amend_partial_update_document(json) if respond_to?(:amend_partial_update_document)

      json
    end

    private

      # elastic_document_value?
      def elastic_search_value(field, mapping)
        value = try field
        return if value.nil?

        value = case mapping[:type]
          when :object
            value.as_search
          when :nested
            value.map(&:as_search)
          else
            value
          end

        if value.present? || value == false
          value
        end
      rescue
        raise "Field not found for #{field.inspect}"
      end
  end
end
