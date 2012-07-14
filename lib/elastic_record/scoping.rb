module ElasticRecord
  module Scoping
    def current_scope #:nodoc:
      Thread.current["#{self}_current_scope"]
    end

    def current_scope=(scope) #:nodoc:
      Thread.current["#{self}_current_scope"] = scope
    end
  end
end