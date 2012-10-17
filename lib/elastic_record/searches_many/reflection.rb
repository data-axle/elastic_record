module ElasticRecord
  module SearchesMany
    class Reflection
      attr_reader :model, :name, :options
      attr_reader :callbacks
      def initialize(model, name, options)
        @model, @name, @options = model, name, options
        @callbacks = define_callbacks(options)
      end

      def klass
        klass_name.constantize
      end

      def klass_name
        name.to_s.classify
      end

      def belongs_to
        options[:as] ? options[:as].to_s : model.name.to_s.demodulize.underscore
      end

      CALLBACKS = [:before_add, :after_add, :before_remove, :after_remove]
      def define_callbacks(options)
        Hash[CALLBACKS.map { |callback_name| [callback_name, Array(options[callback_name.to_sym])] }]
      end

      def touch_column
        if options[:touch]
          options[:touch] == true ? :updated_at : options[:touch].to_sym
        end
      end

      def counter_cache_column
        if options[:counter_cache]
          (options[:counter_cache] == true ? "#{name}_count" : options[:counter_cache]).to_sym
        end
      end
    end
  end
end
