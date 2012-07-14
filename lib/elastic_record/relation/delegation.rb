module ElasticRecord
  class Relation
    module Delegation
      private
        def method_missing(method, *args, &block)
          if Array.method_defined?(method)
            to_a.send(method, *args, &block)
          end
        end
    end
  end
end