module ElasticRecord
  module Callbacks
    def self.included(base)
      return unless base.respond_to?(:after_save) &&  base.respond_to?(:after_destroy)

      base.class_eval do
        after_save if: :changed? do
          self.class.elastic_index.index_record self
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

        if value.present? || value == false
          json[field] = value
        end
      end

      amend_as_search(json) if respond_to?(:amend_as_search)

      json
    end

    def elastic_search_value(field, mapping)
      value = try field
      return if value.nil?

      case mapping[:type]
      when :object
        value.as_search
      when :nested
        value.map(&:as_search)
      else
        value
      end
    end
  end
end
