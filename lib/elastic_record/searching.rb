module ElasticRecord
  module Searching
    def elastic_search
      if current_elastic_search
        current_elastic_search.clone
      else
        relation
      end
    end

    def current_elastic_search #:nodoc:
      Thread.current["#{self}_current_elastic_search"]
    end

    def current_elastic_search=(relation) #:nodoc:
      Thread.current["#{self}_current_elastic_search"] = relation
    end
  end
end