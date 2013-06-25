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
          other_record = other_record.is_a?(Hash) ? klass.new(other_record) : other_record
          other_record.send("#{reflection.belongs_to}=", owner)
          other_record
        end

        delete(load_collection - other_records)
        merge_collections(load_collection, other_records)
        concat(other_records - load_collection)

        if reflection.counter_cache_column
          owner.send("#{reflection.counter_cache_column}=", other_records.size)
        end

        if reflection.touch_column
          owner.send("#{reflection.touch_column}=", Time.current)
        end
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
        records.each do |record|
          callback(:before_remove, record)

          if options[:autosave] || owner.new_record?
            record.mark_for_destruction
          else
            record.destroy
          end

          callback(:after_remove, record)
        end
      end

      def scope
        search = klass.elastic_search.filter("#{reflection.belongs_to}_id" => owner.id).limit(1000000)
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

        collection
      end

      def eager_loaded_collection(records)
        unless @loaded
          @collection = records
          @loaded = true
        end

        collection
      end

      private
        def load_persisted_collection?
          !loaded? || owner.new_record?
        end

        def persisted_collection
          @persisted_collection ||= begin
            if reflection.counter_cache_column && (owner.send(reflection.counter_cache_column).nil? || owner.send(reflection.counter_cache_column) == 0)
              []
            else
              scope.to_a
            end
          end
        end

        def merge_collections(existing_records, new_records)
          return existing_records   if new_records.empty?
          return new_records  if existing_records.empty?

          existing_records.map! do |existing_record|
            if new_record = new_records.delete(existing_record)
              (existing_record.attributes.keys - new_record.changes.keys).each do |name|
                new_record.send("#{name}=", existing_record.send(name))
              end

              new_record
            else
              existing_record
            end
          end

          existing_records + new_records
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
            if callback.respond_to?(:call)
              callback.call(owner, record)
            else
              owner.send(callback, record)
            end
          end
        end
    end
  end
end
