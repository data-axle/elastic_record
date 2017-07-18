require 'elastic_record/index/analyze'
require 'elastic_record/index/configurator'
require 'elastic_record/index/deferred'
require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
require 'elastic_record/index/percolator'
require 'elastic_record/index/settings'

require 'active_support/core_ext/object/deep_dup'

module ElasticRecord
  # ElasticRecord::Index provides access to elastic search's API. It is accessed with
  # <tt>Widget.elastic_index</tt>. The methods provided are:
  #
  # [create]
  #   Create a new index that is not aliased
  # [create_and_deploy]
  #   Create a new index and alias it
  # [reset]
  #   Delete all aliased indexes and deploy a new one
  # [refresh]
  #   Call the refresh API
  # [exists?(index_name)]
  #   Returns if the index exists
  # [get_mapping]
  #   Returns the mapping currently stored by elastic search.
  # [put_mapping]
  #   Update elastic search's mapping
  class Index
    include Documents
    include Manage
    include Mapping, Settings
    include Percolator
    include Analyze
    include Deferred

    attr_accessor :model

    attr_accessor :disabled
    attr_accessor :has_percolator
    attr_accessor :partial_updates

    def initialize(model)
      @model = model
      @disabled = false
    end

    def initialize_copy(other)
      @settings = settings.deep_dup
      @mapping = mapping.deep_dup
    end

    def alias_name=(name)
      @alias_name = name
    end

    def alias_name
      @alias_name ||= model.base_class.name.demodulize.underscore.pluralize
    end

    def type=(name)
      @type = name
    end

    def type
      @type ||= model.base_class.name.demodulize.underscore
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

    def get(end_path, json = nil)
      connection.json_get "/#{alias_name}/#{type}/#{end_path}", json
    end

    private

      def new_index_name
        "#{alias_name}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}"
      end

  end
end
