module ElasticRecord
  module SearchesMany
    class CollectionProxy < ElasticRecord::Relation
      def initialize(association)
        @association = association
        super association.klass, association.klass.arelastic
        merge! association.scope
      end

      def to_a
        if @association.loaded? || !eager_loading?
          @association.load_collection.reject(&:destroyed?)
        else
          loaded = @association.load_collection.reject(&:destroyed?)

          ids = loaded.map(&:id)
          eager_load_values.each do |to_load|
            _belongs_to = @association.reflection.name.to_s.singularize
            _klass = to_load.to_s.singularize.camelize.constantize

            children = _klass.elastic_search.filter("#{_belongs_to}_id" => ids).limit(900)
            loaded.each do |parent|
              children.each do |child|
                if parent.id.to_s == child.send("#{@association.klass.to_s.downcase}_id").to_s
                  siblings = parent.send(to_load.to_s.pluralize)
                  siblings << child unless siblings.detect { |sibling| sibling == child }
                end
              end
            end

          end

          loaded
        end
      end

      def <<(*records)
        @association.concat(records) && self
      end
      alias_method :push, :<<
    end
  end
end
