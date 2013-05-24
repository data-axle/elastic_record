module ElasticRecord
  module SearchesMany
    class Builder
      def self.build(model, name, options)
        new(model, name, options).build
      end

      attr_reader :model, :name, :options
      def initialize(model, name, options)
        @model, @name, @options = model, name, options
      end

      def build
        define_writer
        define_reader

        reflection = ElasticRecord::SearchesMany::Reflection.new(model, name, options)
        model.searches_many_reflections = model.searches_many_reflections.merge(name => reflection)

        model.add_autosave_callbacks(reflection) # if options[:autosave]
      end

      def mixin
        model.generated_searches_many_methods
      end

      def define_writer
        name = self.name
        mixin.redefine_method("#{name}=") do |records|
          searches_many_association(name).writer(records)
        end
      end

      def define_reader
        name = self.name
        mixin.redefine_method(name) do
          searches_many_association(name).reader
        end
      end
    end
  end
end
