require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/admin'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/merging'
require 'elastic_record/relation/none'
require 'elastic_record/relation/search_methods'

module ElasticRecord
  class Relation
    include Admin, Batches, Delegation, FinderMethods, Merging, SearchMethods

    attr_reader :klass, :arelastic, :values

    def initialize(klass, arelastic)
      @klass = klass
      @arelastic = arelastic
      @values = {}
    end

    def count
      search_results['hits']['total']
    end

    def facets
      search_results['facets']
    end

    def explain(id)
      klass.elastic_index.explain(id, as_elastic)
    end

    def initialize_copy(other)
      @values = @values.dup
      reset
    end

    def eager_loading?
      @should_eager_load ||= eager_load_values.any?
    end

    def to_a
      @records ||= begin
        scope = select_values.any? ? klass.select(select_values) : klass
        records = scope.find(to_ids)
        eager_load_associations(records) if eager_loading?
        records
      end
    end

    def to_ids
      search_hits.map { |hit| hit['_id'] }
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
      def reset
        @search_results = @records = nil
        @should_eager_load = nil
      end

      def search_hits
        search_results['hits']['hits']
      end

      def search_results
        @search_results ||= klass.elastic_index.search(as_elastic)
      end

      def eager_load_associations(records)
        ids = records.map(&:id)
        eager_load_values.each do |to_load|
          reflection = ElasticRecord::SearchesMany::Reflection.new(klass, to_load, {})
          belongs_to_id = "#{reflection.belongs_to}_id"
          to_load.to_s.singularize.camelize.constantize.elastic_search.
            filter(belongs_to_id => ids).limit(1000000).group_by { |child| child.send(belongs_to_id) }.
            each do |belongs_to_id, children|
            parent = records.detect { |record| record.id == belongs_to_id }
            parent.send(to_load).eager_loaded(children) if parent
          end
        end
        records
      end
  end
end
