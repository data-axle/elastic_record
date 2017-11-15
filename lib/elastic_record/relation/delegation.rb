module ElasticRecord
  class Relation
    module Delegation
      def to_ary
        to_a.to_ary
      end

      def include?(obj)
        to_a.include?(obj)
      end

      private
        def respond_to_missing?(method, include_private = false)
          super || klass.respond_to?(method, include_private) || Array.method_defined?(method, include_private)
        end

        def method_missing(method, *args, &block)
          if klass.respond_to?(method)
            scoping { klass.send(method, *args, &block) }
          elsif Array.method_defined?(method)
            to_a.send(method, *args, &block)
          else
            super
          end
        end
    end
  end
end
