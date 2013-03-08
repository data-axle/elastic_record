module ElasticRecord
  module Callbacks
    def self.included(base)
      base.class_eval do
        after_save if: :changed? do
          self.class.elastic_index.index_document id, as_search
        end

        after_destroy do
          self.class.elastic_index.delete_document id
        end
      end
    end

    def as_search
      json = {}
      elastic_index.mapping[:properties].each_key do |key|
        next unless respond_to?(key)
        value = value = send(key)

        if value.present? || value == false
          json[key] = value
        end
      end

      amend_as_search(json) if respond_to?(:amend_as_search)

      json
    end
  end
end
