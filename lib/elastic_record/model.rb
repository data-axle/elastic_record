module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Connection
        extend Scoping
        extend ClassMethods
      end
    end

    module ClassMethods
      def relation
        ElasticRecord::Relation.new(self, arelastic)
      end

      def arelastic
        @arelastic ||= Arelastic::Builders::Search.new
      end
    end
  end
end