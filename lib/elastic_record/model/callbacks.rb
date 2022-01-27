module ElasticRecord
  module Model
    module Callbacks
      def self.included(base)
        return unless base.respond_to?(:after_save) &&  base.respond_to?(:after_destroy)

        base.class_eval do
          after_create :index_to_elasticsearch
          after_update :update_index_document, if: -> { respond_to?(:saved_changes?) ? saved_changes? : changed? }
          after_destroy :delete_index_document
        end
      end

      private

        def update_index_document
          method = self.class.elastic_index.partial_updates ? :update_record : :index_record

          self.class.elastic_index.send(method, self)
        end

        def delete_index_document
          self.class.elastic_index.delete_document id
        end
    end
  end
end
