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

      def doctype
        @doctype ||=
          begin
            percolator_doctype = Doctype.new(base_class.name.demodulize.underscore, Doctype::PERCOLATOR_MAPPING)
            percolator_doctype.analysis = percolates_model.doctype.analysis
            percolator_doctype.mapping = percolates_model.doctype.mapping
            percolator_doctype
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
