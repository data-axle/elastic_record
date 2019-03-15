require 'elastic_record/index/analyze'
require 'elastic_record/index/deferred'
require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
require 'elastic_record/index/settings'
require 'elastic_record/index/mapping_type'

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
  # [update_mapping]
  #   Update elastic search's mapping
  class Index
    include Documents
    include Manage
    include Mapping, Settings
    include Analyze
    include Deferred
    include MappingType

    attr_accessor :disabled
    attr_accessor :model
    attr_accessor :partial_updates
    attr_accessor :load_from_source

    def initialize(model)
      @model = model
      @disabled = false
      self.load_from_source = false
    end

    def initialize_copy(other)
      @settings = settings.deep_dup
    end

    def alias_name=(name)
      @alias_name = add_suffix(name)
    end

    def alias_name
      @alias_name ||= add_suffix(model.base_class.name.demodulize.underscore.pluralize)
    end

    def disable!
      @disabled = true
    end

    def enable!
      @disabled = false
    end

    def load_from_source!
      self.load_from_source = true
      model.singleton_class.delegate :find, :find_by, :find_each, :find_in_batches, :first, to: :elastic_search

      model.instance_eval do
        def _insert_record(*args); end
        def _update_record(*args); end
      end
    end

    def loading_from_source(&block)
      self.load_from_source = true
      yield
    ensure
      self.load_from_source = false
    end

    def real_connection
      model.elastic_connection
    end

    def get(end_path, json = nil)
      path = "/#{alias_name}"
      path += "/#{mapping_type}"
      path += "/#{end_path}"

      connection.json_get path, json
    end

    private

      def add_suffix(name)
        suffix = ElasticRecord::Config.index_suffix
        if suffix && !name.end_with?(suffix)
          name + "_#{suffix}"
        else
          name
        end
      end

      def new_index_name
        "#{alias_name}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}"
      end
  end
end
