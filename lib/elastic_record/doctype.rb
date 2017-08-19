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

    PERCOLATOR_MAPPING = {
      "properties" => {
        "query" => {
          "type" => "percolator"
        }
      }
    }

    def self.percolator_doctype
      new('queries', PERCOLATOR_MAPPING)
    end

    def initialize(name, mapping = DEFAULT_MAPPING.deep_dup)
      @name = name
      @mapping = mapping
    end

    def mapping=(custom_mapping)
      mapping.deep_merge!(custom_mapping)
    end

    def ==(other)
      name == other.name && mapping == other.mapping
    end
  end
end
