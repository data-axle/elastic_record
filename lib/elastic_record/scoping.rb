module ElasticRecord
  module Scoping
    def elastic_scoped
      
    end

    def current_elastic_scope #:nodoc:
      Thread.current["#{self}_current_elastic_scope"]
    end

    def current_elastic_scope=(scope) #:nodoc:
      Thread.current["#{self}_current_elastic_scope"] = scope
    end
  end
end