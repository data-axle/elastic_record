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
        @doctype ||=
          begin
            doctype_name = check_mapped_doctype_name || percolates_model.doctype.name
            Doctype.new(doctype_name, Doctype::PERCOLATOR_MAPPING)
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

      private

        def check_mapped_doctype_name
          mapped_doctypes = elastic_connection.json_get("/#{base_class.name.demodulize.underscore.pluralize}/_mapping").values.first['mappings']

          if mapped_doctypes.keys.count > 1
            mapped_percolator_doctype(mapped_doctypes)
          end
        rescue ElasticRecord::ConnectionError
          nil
        end

        def mapped_percolator_doctype(doctypes_map)
          doctypes_map.each_pair do |doctype_name, mapping|
            mapping['properties'].each_value do |value|
              return doctype_name if value == {"type" => "percolator"}
            end
          end
        end
    end
  end
end
