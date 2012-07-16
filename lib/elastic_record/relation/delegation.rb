module ElasticRecord
  module Delegation
    private
      def method_missing(method, *args, &block)
        if Array.method_defined?(method)
          to_a.send(method, *args, &block)
        else
          super
        end
      end
  end
end