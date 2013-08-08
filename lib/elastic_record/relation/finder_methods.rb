module ElasticRecord
  class Relation
    module FinderMethods
      def find(*ids)
        ids = ids.flatten
        case ids.size
        when 0; raise ActiveRecord::RecordNotFound.new('empty argument')
        when 1; filter(arelastic.filter.ids(ids)).first!
        else
          filter(arelastic.filter.ids(ids))
        end
      end

      def first
        find_one self
      end

      def first!
        first or raise ActiveRecord::RecordNotFound
      end

      def last
        find_one reverse_order
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
