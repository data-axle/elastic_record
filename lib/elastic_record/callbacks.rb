module ElasticRecord
  module Callbacks
    def self.included(base)
      return unless base.respond_to?(:after_save) &&  base.respond_to?(:after_destroy)

      base.class_eval do
        after_create do
          self.class.elastic_index.index_record self
        end

        after_update if: :changed? do
          method = self.class.elastic_index.partial_updates ? :update_record : :index_record
          self.class.elastic_index.send(method, self)
        end

        after_destroy do
          self.class.elastic_index.delete_document id
        end
      end
    end

    def as_search
      json = {}

      elastic_index.mapping[:properties].each do |field, mapping|
        value = elastic_search_value field, mapping

        unless value.nil?
          json[field] = value
        end
      end

      amend_as_search(json) if respond_to?(:amend_as_search)

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
