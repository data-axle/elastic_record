module ElasticRecord
  class Doctype
    attr_accessor :name, :mapping, :analysis

    DEFAULT_MAPPING = {
      properties: {
      }
    }

    PERCOLATOR_MAPPING = {
      properties: {
        query: {
          type: "percolator"
        }
      }
    }

    def initialize(name, mapping = DEFAULT_MAPPING.deep_dup)
      @name = name
      @mapping = mapping
      @analysis = {}
    end

    def mapping=(custom_mapping)
      mapping.deep_merge!(custom_mapping)
    end

    def analysis=(custom_analysis)
      analysis.deep_merge!(custom_analysis)
    end

    def ==(other)
      name == other.name && mapping == other.mapping && analysis == other.analysis
    end
  end
end
