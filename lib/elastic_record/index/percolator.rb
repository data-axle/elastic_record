module ElasticRecord
  class Index
    class PercolatorAdapter < Struct.new(:index)
      def delete_percolator_index
        index.delete(percolator_index_name) if percolator_index_exists?
      end

      def percolator_index_exists?
        index.exists?(percolator_index_name)
      end

      def percolator_index_name
        "#{index.alias_name}_percolator"
      end

      def connection
        index.connection
      end
    end

    class PercolatorAdapterV2 < PercolatorAdapter
      def create_percolator(name, elastic_query)
        connection.json_put "/#{percolator_index_name}/.percolator/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/#{percolator_index_name}/.percolator/#{name}"
      end

      def percolator_exists?(name)
        connection.head("/#{percolator_index_name}/.percolator/#{name}") == '200'
      end

      def get_percolator(name)
        json = connection.json_get("/#{percolator_index_name}/.percolator/#{name}")
        json['_source'] if json['found']
      end

      def percolate(document)
        hits = connection.json_get("/#{percolator_index_name}/#{index.type}/_percolate", 'doc' => document)['matches']
        hits.map { |hits| hits['_id'] }
      end

      def all_percolators
        if hits = connection.json_get("/#{percolator_index_name}/.percolator/_search?q=*&size=500")['hits']
          hits['hits'].map { |hit| hit['_id'] }
        end
      end

      def create_percolator_index
        index.create(percolator_index_name) unless percolator_index_exists?
      end
    end

    class PercolatorAdapterV5 < PercolatorAdapter
      def create_percolator(name, elastic_query)
        connection.json_put "/#{percolator_index_name}/queries/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/#{percolator_index_name}/queries/#{name}"
      end

      def percolator_exists?(name)
        connection.head("/#{percolator_index_name}/queries/#{name}") == '200'
      end

      def get_percolator(name)
        json = connection.json_get("/#{percolator_index_name}/queries/#{name}")
        json['_source'] if json['found']
      end

      def percolate(document)
        query = {
          "query" => {
            "percolate" => {
              "field"         => "query",
              "document_type" => "doctype",
              "document"      => document
            }
          }
        }

        hits = connection.json_get("/#{percolator_index_name}/_search", query)['hits']['hits']
        hits.map { |hits| hits['_id'] }
      end

      def all_percolators
        if hits = connection.json_get("/#{percolator_index_name}/queries/_search?q=*&size=500")['hits']['hits']
          hits.map { |hit| hit['_id'] }
        end
      end

      def create_percolator_index
        return if percolator_index_exists?

        connection.json_put "/#{percolator_index_name}", {
          "mappings" => {
            "doctype" => index.doctype.mapping,
            "queries" => {
              "properties" => {
                "query" => {
                  "type" => "percolator"
                }
              }
            }
          },
          "settings" => index.settings
        }
      end
    end

    module Percolator
      delegate :create_percolator, :delete_percolator, :percolator_exists?, :get_percolator, :percolate,
        :all_percolators, :create_percolator_index, :delete_percolator_index, :percolator_index_name,
        to: :percolator_adapter

      def percolator_adapter
        @percolator_adapter ||= percolator_adapter_class.new(self)
      end

      def percolator_adapter_class
        connection.json_get('/')['version']['number'] < '5.0' ? PercolatorAdapterV2 : PercolatorAdapterV5
      end

      def reset_percolators
        delete_percolator_index
        create_percolator_index
      end
    end
  end
end
