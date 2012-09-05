require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'

module ElasticRecord
  class Index
    include Documents
    include Manage
    include Mapping

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

      def json_get(path)
        ActiveSupport::JSON.decode http.get(path).body
      end

      def json_post(path, json)
        http.post(path, ActiveSupport::JSON.encode(json))
      end

      def json_put(path, json)
        http.put(path, ActiveSupport::JSON.encode(json))
      end

      def json_delete(path)
        ActiveSupport::JSON.decode http.delete(path).body
      end

      def connection
        @model.elastic_connection
      end

      def http
        host, port = connection.current_server.split ':'
        Net::HTTP.new(host, port)
      end
  end
end