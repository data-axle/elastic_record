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
  end
end
