module ElasticRecord
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

        def normal_values
          Relation::MULTI_VALUE_METHODS + Relation::SINGLE_VALUE_METHODS
        end

        def merge
          normal_values.each do |name|
            value = values[name]
            relation.send("#{name}!", value) unless value.blank?
          end
          # 
          # Relation::MULTI_VALUE_METHODS.each do |name|
          #   value = values[name]
          # 
          #   unless value.blank?
          #     relation.send("#{name}!", value)
          #     relation.send("#{name}_values").uniq!
          #   end
          # end
        end
      end
  end
end