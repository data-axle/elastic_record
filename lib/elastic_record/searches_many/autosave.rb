module ElasticRecord
  module SearchesMany
    module Autosave
      extend ActiveSupport::Concern

      module ClassMethods
        def add_autosave_callbacks(reflection)
          add_autosave_after_save_callbacks(reflection)
          add_autosave_validation_callbacks(reflection)
        end

        def add_autosave_after_save_callbacks(reflection)
          before_save { save_autosave_records(reflection) }
        end

        def add_autosave_validation_callbacks(reflection)
          validate { validate_autosave_records(reflection) }
        end
      end
    end

    def save_autosave_records(reflection)
      if association = searches_many_instance_get(reflection.name)
        associated_records_to_autosave(association).each do |record|
          if record.marked_for_destruction?
            record.destroy
          elsif record.changed?
            if record.respond_to?(:new_commit) && respond_to?(:new_commit) && new_commit
              record.commit new_commit.options
            else
              record.save
            end
          end
        end
      end      
    end

    def validate_autosave_records(reflection)
      if association = searches_many_instance_get(reflection.name)
        associated_records_to_autosave(association).each do |record|
          unless record.valid?
            record.errors.each do |attribute, message|
              attribute = "#{reflection.name}.#{attribute}"
              errors[attribute] << message
              errors[attribute].uniq!
            end
          end
        end
      end
    end

    def associated_records_to_autosave(association)
      if association.loaded?
        association.load_collection
      else
        []
      end
    end

    # Marks this record to be destroyed as part of the parents save transaction.
    # This does _not_ actually destroy the record instantly, rather child record will be destroyed
    # when <tt>parent.save</tt> is called.
    #
    # Only useful if the <tt>:autosave</tt> option on the parent is enabled for this associated model.
    def mark_for_destruction
      @marked_for_destruction = true
    end

    # Returns whether or not this record will be destroyed as part of the parents save transaction.
    #
    # Only useful if the <tt>:autosave</tt> option on the parent is enabled for this associated model.
    def marked_for_destruction?
      @marked_for_destruction
    end
  end
end