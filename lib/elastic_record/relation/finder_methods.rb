module ElasticRecord
  class Relation
    module FinderMethods
      def find(*ids)
        flattened_ids = ids.flatten
        id_filter     = filter(arelastic.filter.ids(flattened_ids))
        id_filter     = id_filter.limit(flattened_ids.size) unless limit_value

        if ids.first.is_a?(Array)
          id_filter
        else
          case ids.size
          when 0; raise ActiveRecord::RecordNotFound.new('empty argument')
          when 1; id_filter.first!
          else id_filter
          end
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

      def find_by(*args)
        filter(*args).first
      end

      def find_by!(*args)
        filter(*args).first!
      end

      private

        def find_one(relation)
          relation.limit(1).to_a.first
        end
    end
  end
end
