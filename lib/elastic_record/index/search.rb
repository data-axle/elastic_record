require 'active_support/core_ext/object/to_query'

module ElasticRecord
  class Index
    module Search
      def record_exists?(id)
        get_doc(id)['found']
      end

      def search(elastic_query, options = {})
        url = "_search"
        url += "?#{options.to_query}" if options.any?

        get url, elastic_query
      end

      def multi_search(headers_and_bodies, options = {})
        url = "_msearch"
        url += "?#{options.to_query}" if options.any?

        queries = headers_and_bodies.flat_map { |header, body| [header.to_json, body.to_json] }
        queries = queries.join("\n") + "\n"
        get url, queries
      end

      def explain(id, elastic_query)
        get "_explain", elastic_query
      end
    end
  end
end
