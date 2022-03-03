module ElasticRecord
  module Model
    module Joining
      class JoinChild
        attr_reader :klass, :name, :children, :parent_id_accessor

        def self.build_children(user_input)
          Array.wrap(user_input).map do |join_child|
            join_child.is_a?(self) ? join_child : new(klass: join_child)
          end
        end

        def initialize(klass:, name: nil, children: [], parent_id_accessor: nil, parent_accessor: nil)
          unless klass.is_a?(Class) && klass < ElasticRecord::Model
            raise "JoinChild#klass must be instances of `ElasticRecord::Model`. Cannot be #{klass}!"
          end

          if klass.instance_methods.include?(:es_join_name)
            raise "Cannot initialize a #{self.class} with a klass that is already a parent!  Remove the call to has_es_children from #{klass}."
          end

          if parent_accessor
            unless parent_accessor.respond_to?(:call) || (klass.instance_methods + klass.private_instance_methods).include?(parent_accessor.to_sym)
              raise "parent_accessor must be callable for #{klass}"
            end
          end

          if parent_id_accessor
            unless parent_id_accessor.respond_to?(:call) || (klass.instance_methods + klass.private_instance_methods).include?(parent_id_accessor.to_sym)
              raise "parent_id_accessor must be callable for #{klass}"
            end
          end

          name ||= klass.to_s.demodulize.underscore

          children = Array.wrap(children)
          children.each do |child|
            unless child.is_a?(self.class)
              raise "JoinChild#children can only contain #{self.class}. Cannot be #{child}!"
            end
          end

          @klass, @name, @children, @parent_id_accessor = klass, name, children, parent_id_accessor
        end

        def assign_to_parent!(parent:)
          unless parent < ElasticRecord::Model
            raise "Parent must be instances of `ElasticRecord::Model`. #{parent} cannot be parent!"
          end

          unless parent.respond_to?(:es_join_field)
            raise "Don't call #{self.class}#assign_to_parent! directly!  It's for internal use only."
          end

          join_field = parent.es_join_field
          if (klass.instance_methods + klass.private_instance_methods).include?(join_field.to_sym)
            raise "Naming your join field '#{join_field}' on #{parent} will clobber an existing #{klass} method with that name!  Choose a different name!"
          end

          if parent.instance_methods.include?(:routing)
            parent_accessor = self.parent_accessor

            if parent_accessor.nil?
              parent_accessor = parent.es_join_name
              unless (klass.instance_methods + klass.private_instance_methods).include?(parent_accessor.to_sym)
                raise "#{klass} does not respond to #{parent_accessor}.  Please specify a parent_accessor for #{self.class}(klass: #{klass})!"
              end
            end
          end

          name = self.name
          parent_id_accessor = self.parent_id_accessor

          if parent_id_accessor.nil?
            parent_id_accessor = "#{parent.es_join_name}_id"
            unless (klass.instance_methods + klass.private_instance_methods).include?(parent_id_accessor.to_sym)
              raise "#{klass} does not respond to #{parent_id_accessor}.  Please specify a parent_id_accessor for #{self.class}(klass: #{klass})!"
            end
          end
          klass.define_singleton_method(:es_root) { parent.es_root }
          klass.define_singleton_method(:es_join_field) { join_field }
          klass.define_singleton_method(:es_join_name) { name }
          klass.define_method(:es_join_name) { name }
          klass.define_method(join_field) do
            parent_id = parent_id_accessor.respond_to?(:call) ? instance_exec(&parent_id_accessor) : send(parent_id_accessor)
            { 'name' => es_join_name.to_s, 'parent' => parent_id }
          end
          klass.define_method(:routing) do
            if parent.instance_methods.include?(:routing)
              parent_instance = parent_accessor.respond_to?(:call) ? instance_exec(&parent_accessor) : send(parent_accessor)
              parent_instance.routing
            else
              parent_id_accessor.respond_to?(:call) ? instance_exec(&parent_id_accessor) : send(parent_id_accessor)
            end
          end

          klass.elastic_index.alias_name = parent.es_root.elastic_index.alias_name
          klass.elastic_index.disable_index_creation = true
          parent.es_root.elastic_index.mapping.merge!(klass.elastic_index.mapping)

          children.each { |child| child.assign_to_parent!(parent: klass) }
        end

        def relations
          children.map(&:relations).inject({ name => children.map(&:name) }, :merge)
        end
      end

      def has_es_children(join_field:, name: nil, children:)
        join_children = ElasticRecord::Model::Joining::JoinChild.build_children(children)

        if (instance_methods + private_instance_methods).include?(join_field.to_sym)
          raise "Naming your join field '#{join_field}' will clobber an existing #{self} method with that name!  Choose a different name!"
        end

        name ||= to_s.demodulize.underscore
        klass = self
        define_singleton_method(:es_root) { klass }
        define_singleton_method(:es_join_field) { join_field }
        define_singleton_method(:es_join_name) { name }
        define_method(:es_join_name) { name }
        define_method(join_field) do
          { 'name' => es_join_name.to_s }
        end

        join_children.each { |child| child.assign_to_parent!(parent: self)}
        relations = join_children.map(&:relations).inject({ name => join_children.map(&:name) }, :merge).keep_if { |k, v| v.present? }
        elastic_index.mapping[:properties][join_field] = { type: "join", relations: relations }
      end
    end
  end
end
