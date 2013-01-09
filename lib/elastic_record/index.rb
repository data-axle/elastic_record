require 'elastic_record/index/configurator'
require 'elastic_record/index/deferred'
require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
require 'elastic_record/index/percolator'
require 'elastic_record/index/settings'

require 'active_support/core_ext/hash/deep_dup'

module ElasticRecord
  class Index
    include Documents
    include Manage
    include Mapping
    include Percolator
    include Settings
    include Deferred

    attr_accessor :model
    attr_accessor :disabled

    def initialize(model)
      @model = model
      @disabled = false
    end

    def initialize_copy(other)
      @settings = settings.deep_dup
      @mapping = mapping.deep_dup
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

    def real_connection
      model.elastic_connection
    end

    def configure(&block)
      Configurator.new(self).instance_eval(&block)
    end

    private
      def new_index_name
        "#{alias_name}_#{Time.now.to_i}"
      end
  end
end