module ElasticRecord
  module Scoping
    def elastic_scoped
      if current_elastic_scope
        current_elastic_scope.clone
      else
        relation
      end
    end

    def current_elastic_scope #:nodoc:
      Thread.current["#{self}_current_elastic_scope"]
    end

    def current_elastic_scope=(scope) #:nodoc:
      Thread.current["#{self}_current_elastic_scope"] = scope
    end
  end
end