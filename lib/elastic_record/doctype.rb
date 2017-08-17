module ElasticRecord
  class Doctype
    attr_accessor :name, :mapping

    DEFAULT_MAPPING = {
      properties: {
      },
      _all: {
        enabled: false
      }
    }
    def initialize(name, mapping = DEFAULT_MAPPING.deep_dup)
      @name = name
      @mapping = mapping
    end

    def mapping=(custom_mapping)
      mapping.deep_merge!(custom_mapping)
    end
  end
end
