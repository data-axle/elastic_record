module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        include Callbacks

        extend Connection, Searching, ClassMethods
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

    def arelastic
      self.class.arelastic
    end

    def elastic_index
      self.class.elastic_index
    end
  end
end
