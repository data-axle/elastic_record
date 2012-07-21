module ElasticRecord
  module Searching
    def elastic_search
      if current_elastic_search
        current_elastic_search.clone
      else
        relation
      end
    end

    def elastic_scope(name, body, &block)
      extension = Module.new(&block) if block

      singleton_class.send(:define_method, name) do |*args|
        relation = body.call(*args)
        relation = elastic_search.merge(relation)

        extension ? relation.extending(extension) : relation
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