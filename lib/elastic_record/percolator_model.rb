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
            index = ElasticRecord::Index.new([self, percolates_model])
            index.partial_updates = false
            index
          end
      end

      def doctype
        @doctype ||= Doctype.percolator_doctype
      end

      def percolate(document)
        query = {
          "percolate" => {
            "field"         => "query",
            "document_type" => doctype.name,
            "document"      => document
          }
        }

        elastic_search.filter(query).limit(5000)
      end
    end
  end
end
