module ElasticRecord
  class Index
    class Configurator
      attr_reader :index
      def initialize(index)
        @index = index
      end

      def property(name, options)
        index.mapping[:properties][name.to_sym] = options
      end

      def has_percolator!
        index.has_percolator = true
      end
    end
  end
end
