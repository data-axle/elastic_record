module ElasticRecord
  module Callbacks
    def self.included(base)
      return unless base.respond_to?(:after_save) && base.respond_to?(:after_destroy)

      base.class_eval do
        after_save do
          self.class.elastic_index.index_record self
        end

        after_destroy do
          self.class.elastic_index.delete_record self
        end
      end
    end
  end
end
