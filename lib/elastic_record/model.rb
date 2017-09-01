module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Searching
        extend ClassMethods
        include Callbacks
        include AsDocument
        include NameCache

        class_attribute :elastic_connection
        self.elastic_connection = ElasticRecord::Connection.new(ElasticRecord::Config.servers, ElasticRecord::Config.connection_options)
      end
    end

    module ClassMethods
      def inherited(child)
        super

        if child < child.base_class
          child.elastic_index = elastic_index.dup
          child.doctype = doctype.dup
        end
      end

      def arelastic
        Arelastic::Builders::Search
      end

      def doctype
        @doctype ||= Doctype.new(base_class.name.demodulize.underscore)
      end

      def doctype=(new_doctype)
        @doctype = new_doctype
      end

      def elastic_index
        @elastic_index ||= ElasticRecord::Index.new(self)
      end

      def elastic_index=(index)
        @elastic_index = index
      end
    end

    def arelastic
      self.class.arelastic
    end

    def elastic_index
      self.class.elastic_index
    end

    def doctype
      self.class.doctype
    end
  end
end
