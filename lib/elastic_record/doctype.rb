module ElasticRecord
  class Doctype
    attr_accessor :name, :mapping, :analysis

    DEFAULT_MAPPING = {
      properties: {
      },
      _all: {
        enabled: false
      }
    }

    PERCOLATOR_MAPPING = {
      properties: {
        query: { type: 'percolator' }
      }
    }

    def initialize(name, mapping = DEFAULT_MAPPING.deep_dup)
      @name = name
      @mapping = mapping.deep_symbolize_keys
      @analysis = {}
    end

    def mapping=(custom_mapping)
      mapping.deep_merge!(custom_mapping.deep_symbolize_keys)
    end

    def analysis=(custom_analysis)
      analysis.deep_merge!(custom_analysis)
    end

    def ==(other)
      name == other.name && mapping == other.mapping && analysis == other.analysis
    end
  end
end
