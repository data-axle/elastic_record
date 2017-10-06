require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/hits'
require 'elastic_record/relation/merging'
require 'elastic_record/relation/none'
require 'elastic_record/relation/search_methods'

module ElasticRecord
  class Relation
    include Batches, Delegation, FinderMethods, Hits, Merging, SearchMethods

    attr_reader :klass, :values

    def initialize(klass)
      @klass = klass
      @values = {}
    end

    def count
      search_results['hits']['total']
    end

    def aggregations
      search_results['aggregations']
    end

    def explain(id)
      klass.elastic_index.explain(id, as_elastic)
    end

    def initialize_copy(other)
      @values = @values.dup
      reset
    end

    def to_a
      @records ||= load_hits(search_hits)
    end

    def to_ids
      map_hits_to_ids search_hits
    end

    def delete_all
      find_ids_in_batches { |ids| klass.delete(ids) }
      klass.elastic_index.delete_by_query(as_elastic)
    end

    def ==(other)
      to_a == other
    end

    def inspect
      to_a.inspect
    end

    def scoping
      previous, klass.current_elastic_search = klass.current_elastic_search, self
      yield
    ensure
      klass.current_elastic_search = previous
    end

    private

      def search_hits
        search_results['hits']['hits']
      end

      def reset
        @search_results = @records = nil
      end

      def search_results
        @search_results ||= begin
          options = search_type_value ? {search_type: search_type_value} : {}
          search = as_elastic.update('_source' => klass.elastic_index.load_from_source)

          klass.elastic_index.search(search, options)
        end
      end
  end
end
