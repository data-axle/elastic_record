module ElasticRecord
  class Relation
    module SearchMethods
      class FilterChain
        def initialize(scope)
          @scope = scope
        end

        def not(*filters)
          add_filter_nodes_to_scope(filters) do |filter_node|
            Arelastic::Filters::Not.new(filter_node)
          end
        end

        def nested(path, *filters)
          add_filter_nodes_to_scope(filters) do |filter_node|
            Arelastic::Filters::Nested.new(path, filter_node)
          end
        end

        def add_filter_nodes_to_scope(filters)
          filter_value = @scope.send(:build_filter_nodes, filters).map do |filter_node|
            yield filter_node
          end

          @scope.filter_values += filter_value
          @scope
        end
      end

      Relation::MULTI_VALUE_METHODS.each do |name|
        define_method "#{name}_values" do
          @values[name] || []
        end

        define_method "#{name}_values=" do |values|
          @values[name] = values
        end
      end

      Relation::SINGLE_VALUE_METHODS.each do |name|
        define_method "#{name}_value" do
          @values[name]
        end

        define_method "#{name}_value=" do |value|
          @values[name] = value
        end
      end

      def query!(value)
        self.query_value = value
        self
      end

      def query(value)
        clone.query! value
      end

      def filter!(*args)
        self.filter_values += args
        self
      end

      def filter(opts = :chain, *rest)
        if opts == :chain
          FilterChain.new(clone)
        else
          clone.filter!(opts, *rest)
        end
      end

      def find_by(*args)
        filter(*args).first
      end

      def find_by!(*args)
        filter(*args).first!
      end

      def limit!(value)
        self.limit_value = value
        self
      end

      def limit(value)
        clone.limit!(value)
      end

      def offset!(value)
        self.offset_value = value
        self
      end

      def offset(value)
        clone.offset! value
      end

      def select!(*args)
        self.select_values += args.flatten
        self
      end

      def select(*args, &block)
        if block_given?
          to_a.select(&block)
        else
          clone.select! *args
        end
      end

      def search_type!(type)
        self.search_type_value = type
        self
      end

      def search_type(type)
        clone.search_type! type
      end

      def aggregate!(aggregation)
        self.aggregation_values += [aggregation]
        self
      end

      def aggregate(aggregation)
        clone.aggregate! aggregation
      end

      def order!(*args) # :nodoc:
        self.order_values += args.flatten
        self
      end

      def order(*args)
        clone.order! *args
      end

      # Reverse the existing order clause on the relation.
      #
      #   User.order('name').reverse_order # generated search has 'sort: {'name' => :desc}
      def reverse_order
        clone.reverse_order!
      end

      def reverse_order! # :nodoc:
        self.reverse_order_value = !reverse_order_value
        self
      end

      def extending!(*modules, &block)
        modules << Module.new(&block) if block_given?

        self.extending_values += modules.flatten
        extend(*extending_values)

        self
      end

      def extending(*modules, &block)
        clone.extending!(*modules, &block)
      end

      def none
        extending(None)
      end

      def as_elastic
        build_search.as_elastic
      end

      private
        def build_search
          searches = [
            build_query_and_filter(query_value, filter_values),
            build_limit(limit_value),
            build_offset(offset_value),
            build_aggregations(aggregation_values),
            build_orders(order_values)
          ].compact

          Arelastic::Nodes::HashGroup.new searches
        end

        def build_query_and_filter(query, filters)
          query = build_query(query)
          filter = build_filter(filters)
          if filter
            arelastic.query.filtered(filter: filter, query: query)
          elsif query
            Arelastic::Searches::Query.new(query)
          else
            arelastic.query.match_all
          end
        end

        def build_query(query)
          if query.is_a?(String)
            query = Arelastic::Queries::QueryString.new query
          end

          query
        end

        def build_filter(filters)
          nodes = build_filter_nodes(filters)

          if nodes.size == 1
            nodes.first
          elsif nodes.size > 1
            Arelastic::Filters::And.new(nodes)
          end
        end

        def build_filter_nodes(filters)
          filters.each_with_object([]) do |filter, nodes|
            if filter.is_a?(Arelastic::Filters::Filter)
              nodes << filter
            elsif filter.is_a?(ElasticRecord::Relation)
              nodes << Arelastic::Filters::HasChild.new(filter.elastic_index.type, filter.as_elastic['query'])
            else
              filter.each do |field, terms|
                case terms
                when Array, Range
                  nodes << arelastic[field].in(terms)
                when Hash
                  nodes << {field => terms}
                when nil
                  nodes << arelastic[field].missing
                else
                  nodes << arelastic[field].eq(terms)
                end
              end
            end
          end
        end

        def build_limit(limit)
          if limit
            Arelastic::Searches::Size.new(limit)
          end
        end

        def build_offset(offset)
          if offset
            Arelastic::Searches::From.new(offset)
          end
        end

        def build_aggregations(aggregations)
          Arelastic::Searches::Aggregations.new(aggregations) unless aggregations.empty?
        end

        def build_orders(orders)
          return if orders.empty?

          orders = orders.map do |order|
            if order.is_a?(Arelastic::Sorts::Sort)
              order
            else
              Arelastic::Sorts::Sort.new(order)
            end
          end

          orders = reverse_query_order(orders) if reverse_order_value
          Arelastic::Searches::Sort.new(orders)
        end

        def reverse_query_order(orders)
          orders.reverse.map do |order|
            order.reverse
          end
        end
    end
  end
end
