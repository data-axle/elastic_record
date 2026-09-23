module ElasticRecord
  module Model
    module Callbacks
      def self.included(base)
        return unless base.respond_to?(:after_commit)

        base.class_eval do
          after_commit :index_to_elasticsearch, on: :create
          after_commit :update_index_document, on: :update, if: -> { respond_to?(:saved_changes?) ? saved_changes? : changed? }
          after_commit :delete_index_document, on: :destroy
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
