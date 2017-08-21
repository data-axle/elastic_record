module ElasticRecord
  class Relation
    module Admin
      def create_warmer(name)
        klass.elastic_index.create_warmer(name, as_elastic)
      end
    end
  end
end
