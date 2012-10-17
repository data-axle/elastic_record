require 'elastic_record/searches_many/association'
require 'elastic_record/searches_many/autosave'
require 'elastic_record/searches_many/builder'
require 'elastic_record/searches_many/collection_proxy'
require 'elastic_record/searches_many/reflection'

module ElasticRecord
  module SearchesMany
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        class_attribute :searches_many_reflections
        self.searches_many_reflections = {}

        include ElasticRecord::SearchesMany::Autosave
      end
    end

    module ClassMethods
      # Specifies a one-to-many association. The following methods for retrieval and query of
      # collections of associated objects will be added:
      # 
      # [collection]
      #   Returns an array of all the associated objects.
      # [collection=objects]
      #   Replaces the collections content by deleting and adding objects as appropriate.
      # [collection_params=objects]
      #   Support for nested assignment from a form
      # === Options
      # [:as]
      #   Specifies a polymorphic interface (See <tt>belongs_to</tt>).
      # [:touch]
      #   Specify to update the owner when changed. Specify <tt>true</tt>
      #   to update the updated_at field. If you specify a symbol, that attribute
      #   will be updated with the current time in addition to the updated_at/on attribute.
      # [:autosave]
      #   If true, always save the associated objects or destroy them if marked for destruction, when
      #   saving the parent object.
      # [:counter_cache]
      #   Caches the number of belonging objects on the associate class. This requires that a column
      #   named <tt>#{table_name}_count</tt> (such as +comments_count+ for a belonging Comment class)
      #   is used on the associate class (such as a Post class). You can also specify a custom counter
      #   cache column by providing a column name instead of a +true+/+false+ value to this
      #   option (e.g., <tt>:counter_cache => :my_custom_counter</tt>.)
      # 
      # === Example
      # 
      # Example: A Firm class declares <tt>has_many :clients</tt>, which will add:
      # * <tt>Firm#clients</tt>
      # * <tt>Firm#clients=(objects)</tt>
      # * <tt>Firm#client_params=(params)</tt>
      def searches_many(name, options = {})
        ElasticRecord::SearchesMany::Builder.build(self, name, options)
      end

      def generated_searches_many_methods
        @generated_searches_many_methods ||= begin
          mod = const_set(:GeneratedSearchesManyMethods, Module.new)
          include mod
          mod
        end
      end
    end

    # Returns the searches_many instance for the given name, instantiating it if it doesn't already exist
    def searches_many_association(name)
      association = searches_many_instance_get(name)

      if association.nil?
        association = ElasticRecord::SearchesMany::Association.new(self, searches_many_reflections[name])
        searches_many_instance_set(name, association)
      end

      association
    end

    private
      def searches_many_cache
        @searches_many_cache ||= {}
      end

      def searches_many_instance_get(name)
        searches_many_cache[name.to_sym]
      end
    
      def searches_many_instance_set(name, association)
        searches_many_cache[name.to_sym] = association
      end
  end
end