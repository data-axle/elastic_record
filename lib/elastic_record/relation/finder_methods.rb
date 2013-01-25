module ElasticRecord
  class Relation
    module FinderMethods
      def find(id)
        filter(arelastic.filter.ids(id)).to_a.first || (raise ActiveRecord::RecordNotFound)
      end

      def first
        find_one self
      end

      def last
        find_one order('color' => 'reverse')
      end

      def all
        to_a
      end

      private

        def find_one(relation)
          relation.limit(1).to_a.first
        end
    end
  end
end