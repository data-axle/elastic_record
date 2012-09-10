require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
require 'elastic_record/index/percolator'
require 'net/http'

module ElasticRecord
  class Index
    include Documents
    include Manage
    include Mapping
    include Percolator

    attr_accessor :model
    attr_accessor :disabled

    def initialize(model)
      @model = model
      @disabled = false
    end

    def alias_name
      @alias_name ||= model.base_class.model_name.collection
    end

    def type
      @type ||= model.base_class.model_name.element
    end

    def disable!
      @disabled = true
    end

    def enable!
      @disabled = false
    end

    private
      def new_index_name
        "#{alias_name}_#{Time.now.to_i}"
      end

      def connection
        model.elastic_connection
      end
  end
end