module ElasticRecord
  module Batches
    def find_each
      find_in_batches do |records|
        records.each { |record| yield record }
      end
    end

    def find_in_batches(options = {})
      options[:size] ||= 100
      options[:scroll]  ||= '20m'
      options[:search_type] = 'scan'

      hits = klass.elastic_connection.search(as_elastic, options)

      klass.elastic_connection.scroll(hits.scroll_id, scroll: options[:scroll], ids_only: true) do |hits|
        yield klass.find(hits.to_a)
      end
    end
  end
end