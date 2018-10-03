module ElasticRecord
  module PercolatorModel
    def self.included(base)
      base.class_eval do
        class_attribute :percolates_model

        include Model
        extend ClassMethods
      end
    end

    module ClassMethods
      DEFAULT_PERCOLATOR_MAPPING = {
        properties: {
          query: { type: 'percolator' }
        }
      }
      def elastic_index
        @elastic_index ||=
          begin
            index = ElasticRecord::Index.new(self)
            index.mapping = DEFAULT_PERCOLATOR_MAPPING
            index.mapping = percolates_model.elastic_index.mapping
            index.partial_updates = false
            index
          end
      end

      def percolate(document)
        query = Arelastic::Queries::Percolate.new("query", document)

        elastic_search.filter(query).limit(5000)
      end
    end
  end
end
