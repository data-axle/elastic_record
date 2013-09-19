module ElasticRecord
  module Callbacks
    def self.included(base)
      base.class_eval do
        # after_create do
        #   self.class.elastic_index.index_record self
        # end

        after_save if: :changed? do
          self.class.elastic_index.index_record self
        end

        after_destroy do
          self.class.elastic_index.delete_document id
        end
      end
    end

    def as_dirty_search
      as_search { |key| attribute_changed?(key.to_s) }
    end

    def as_search
      json = {}

      elastic_index.mapping[:properties].each do |key, value|
        next if !respond_to?(key) || value[:type] == 'object'
        next if block_given? && !yield(key)
        value = send(key)

        if value.present? || value == false
          json[key] = value
        end
      end

      amend_as_search(json) if respond_to?(:amend_as_search)

      json
    end
  end
end
