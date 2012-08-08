module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Connection
        extend Searching
        extend ClassMethods
      end
    end

    module ClassMethods
      def elastic_relation
        ElasticRecord::Relation.new(self, arelastic)
      end

      def arelastic
        @arelastic ||= Arelastic::Builders::Search.new
      end

      def elastic_index
        @elastic_index ||= ElasticRecord::Index.new(self)
      end
    end
  end
end
