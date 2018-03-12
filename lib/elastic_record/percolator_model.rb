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
      def elastic_index
        @elastic_index ||=
          begin
            index = ElasticRecord::Index.new(self)
            index.partial_updates = false
            index
          end
      end

      def percolate(document)
        query = {
          "percolate" => {
            "field"         => "query",
            "document"      => document
          }
        }

        elastic_search.filter(query).limit(5000)
      end
    end
  end
end
