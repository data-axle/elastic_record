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
  #   # Must return an Arelastic::Search
  #   def as_arelastic
  #   end
  # end
  module PercolatorModel
    extend Model

    def self.included(base)
      base.class_eval do
        class_attribute :target_model

        extend ClassMethods
      end
    end

    module ClassMethods
      def elastic_index
        @elastic_index ||=
          begin
            index = ElasticRecord::Index.new([self, target_model])
          end
      end

      def doctype
        @doctype ||= Doctype.percolator_doctype
      end
    end

    def as_search
      as_arelastic.as_elastic
    end

    def as_partial_update_document
      as_search
    end
  end
end
