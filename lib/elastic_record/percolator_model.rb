module ElasticRecord
  # PercolatorModel are models that should be registered
  # as elastic queries.
  #
  # Must specify the target type and how to represent itself
  # as an Arelastic::Search
  #
  # E.x.
  #
  # class WidgetQuery
  #   include ElasticRecord::PercolatorRecord
  #
  #   # Must be an ElasticRecord::Model
  #   target_model Widget
  #
  #   # Must return an Elastic Search query
  #   def as_search
  #   end
  #
  #   # [optional] - To change how the target model is percolated
  #   # Must return a Hash
  #   def self.as_percolated_document(target_model)
  #   end
  # end
  module PercolatorModel
    def self.included(base)
      base.class_eval do
        class_attribute :target_model

        include Model
        extend ClassMethods
      end
    end

    module ClassMethods
      def elastic_index
        @elastic_index ||=
          begin
            index = ElasticRecord::Index.new([self, target_model])
            index.partial_updates = false
            index
          end
      end

      def doctype
        @doctype ||= Doctype.percolator_doctype
      end

      def percolate(other_model)
        query = {
          "query" => {
            "percolate" => {
              "field"         => "query",
              "document_type" => target_model.doctype.name,
              "document"      => as_percolated_document(other_model)
            }
          }
        }

        hits = elastic_index.search(query)['hits']['hits']
        ids = hits.map { |hits| hits['_id'] }

        where(id: ids)
      end

      private

        def as_percolated_document(model)
          model.attributes
        end
    end
  end
end
