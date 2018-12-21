module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Searching
        extend ClassMethods
        include Callbacks
        include AsDocument

        class_attribute :elastic_connection
        self.elastic_connection = ElasticRecord::Connection.new(ElasticRecord::Config.servers, ElasticRecord::Config.connection_options)

        singleton_class.delegate :query, :filter, :aggregate, to: :elastic_search
      end
    end

    module ClassMethods
      def inherited(child)
        super

        if child < child.base_class
          child.elastic_index = elastic_index.dup
          child.elastic_index.model = child
          child.elastic_index.mapping_type = elastic_index.mapping_type
        end
      end

      def arelastic
        Arelastic::Builders::Search
      end

      def elastic_index
        @elastic_index ||= ElasticRecord::Index.new(self)
      end

      def elastic_index=(index)
        @elastic_index = index
      end
    end

    def index_to_elasticsearch
      elastic_index.index_record(self)
    end

    def arelastic
      self.class.arelastic
    end

    def elastic_index
      self.class.elastic_index
    end
  end
end
