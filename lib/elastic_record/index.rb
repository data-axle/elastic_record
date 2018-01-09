require 'elastic_record/index/analyze'
require 'elastic_record/index/deferred'
require 'elastic_record/index/documents'
require 'elastic_record/index/bulk_documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
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
  # [update_mapping]
  #   Update elastic search's mapping
  class Index
    include Documents
    include BulkDocuments
    include Manage
    include Mapping, Settings
    include Analyze
    include Deferred

    attr_accessor :doctypes

    attr_accessor :disabled
    attr_accessor :model
    attr_accessor :partial_updates
    attr_accessor :load_from_source

    def initialize(models)
      models = Array.wrap(models)
      @model = models.first
      @doctypes = models.map(&:doctype)
      @disabled = false
      @load_from_source = false
    end

    def initialize_copy(other)
      @settings = settings.deep_dup
    end

    def alias_name=(name)
      @alias_name = name
    end

    def alias_name
      @alias_name ||= model.base_class.name.demodulize.underscore.pluralize
    end

    def disable!
      @disabled = true
    end

    def enable!
      @disabled = false
    end

    def loading_from_source(&block)
      @load_from_source = true
      yield
    ensure
      @load_from_source = false
    end

    def real_connection
      model.elastic_connection
    end

    def get(end_path, doctype = nil, json = nil)
      path = "/#{alias_name}"
      path += "/#{doctype.name}" if doctype
      path += "/#{end_path}"

      connection.json_get path, json
    end

    private

      def new_index_name
        "#{alias_name}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}"
      end
  end
end
