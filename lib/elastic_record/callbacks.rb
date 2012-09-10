module ElasticRecord
  module Callbacks
    def self.included(base)
      base.class_eval do
        after_save do
          self.class.elastic_index.index_document id, as_search
        end

        after_destroy do
          self.class.elastic_index.delete_document id
        end
      end
    end
  end
end
