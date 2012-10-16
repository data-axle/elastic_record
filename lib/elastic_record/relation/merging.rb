module ElasticRecord
  class Relation
    module Merging
      def merge!(other)
        Merger.new(self, other).merge
      end

      def merge(other)
        clone.merge!(other)
      end

      private
        class Merger
          attr_accessor :relation, :values

          def initialize(relation, other)
            @relation = relation
            @values = other.values
          end

          def merge
            Relation::SINGLE_VALUE_METHODS.each do |name|
              value = values[name]
              relation.send("#{name}!", value) unless value.blank?
            end

            Relation::MULTI_VALUE_METHODS.each do |name|
              value = values[name]
              relation.send("#{name}!", *value) unless value.blank?
            end

            relation
          end
        end
    end
  end
end