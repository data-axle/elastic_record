module ElasticRecord
  module Batches
    def find_each
      options = {scroll: '20m', size: 100, search_type: 'scan'}

      hits = klass.elastic_connection.search(as_elastic, options)

      klass.elastic_connection.scroll(hits.scroll_id, scroll: options[:scroll], ids_only: true) do |hits|
        records = klass.find(hits.to_a)
        records.each { |record| yield record }
      end
    end
  end
end