require 'active_support/core_ext/module/delegation'

module ElasticRecord
  module SearchesMany
    class Association
      attr_reader :owner, :reflection, :collection

      delegate :klass, :options, to: :reflection

      def initialize(owner, reflection)
        @owner      = owner
        @reflection = reflection
        @collection = []
        @loaded     = false
      end

      def writer(other_records)
        other_records = other_records.map do |other_record|
          other_record.is_a?(Hash) ? klass.new(other_record) : other_record
        end

        if reflection.counter_cache_column
          owner.send("#{reflection.counter_cache_column}=", other_records.size)
        end

        if reflection.touch_column
          owner.send("#{reflection.touch_column}=", Time.current)
        end

        delete(load_collection - other_records)
        merge_collections(load_collection, other_records)
        concat(other_records - load_collection)
      end
  
      def reader
        CollectionProxy.new(self)
      end

      def loaded?
        @loaded
      end

      def concat(*records)
        load_collection if owner.new_record?

        result = true

        records.flatten.each do |record|
          add_to_collection(record) do |r|
            result &&= record.save unless owner.new_record?
          end
        end

        result && records
      end

      def delete(records)
        if options[:autosave] || owner.new_record?
          records.each(&:mark_for_destruction)
        else
          record.destroy
        end
      end

      def scope
        search = klass.elastic_search.filter "#{reflection.belongs_to}_id" => owner.id
        if options[:as]
          search.filter! "#{reflection.belongs_to}_type" => owner.class.name
        end
        search
      end

      def load_collection
        unless @loaded
          @collection = merge_collections(persisted_collection, collection)
          @loaded = true
        end

        loaded = true
        collection
      end

      private
        def load_persisted_collection?
          !loaded? || owner.new_record?
        end

        def persisted_collection
          scope.to_a
        end

        def merge_collections(existing, additions)
          p "merging #{existing.inspect} with #{additions.inspect}"
          return existing   if additions.empty?
          return additions  if existing.empty?

          existing.map! do |record|
            if mem_record = additions.delete(record)

              (record.attributes.keys - mem_record.changes.keys).each do |name|
                mem_record.send("#{name}=", record.send(name))
              end

              mem_record
            else
              record
            end
          end

          existing + additions
        end

        def add_to_collection(record)
          callback(:before_add, record)

          record.send("#{reflection.belongs_to}=", owner)
          yield(record) if block_given?
          @collection << record

          callback(:after_add, record)

          record
        end

        def callback(method, record)
          reflection.callbacks[method].each do |callback|
            if callback.is_a?(Symbol)
              owner.send(callback, record)
            else
              callback.call(owner, record)
            end
          end
        end
    end
  end
end