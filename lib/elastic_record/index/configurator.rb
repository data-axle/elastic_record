module ElasticRecord
  class Index
    class Configurator
      attr_reader :index

      def initialize(index)
        @index = index
      end
    end
  end
end
