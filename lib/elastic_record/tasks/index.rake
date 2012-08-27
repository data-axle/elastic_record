module ElasticRecord
  module Task
    def get_models
      if class_name = ENV['CLASS']
        [class_name.camelize.constantize]
      else
        IndexedModels.all
      end
    end
  end
end

namespace :index do
  desc "Create index for CLASS or all models."
  task create: :environment do
    ElasticRecord::Task.get_models.each do |model|
      begin
        model.create_index!
        logger.info "Created #{model.name} index"
      rescue => e
        if e.message =~ /IndexAlreadyExistsException/
          logger.info "#{model.name} index already exists"
        else
          raise e
        end
      end
    end
  end

  desc "Drop index for CLASS or all models."
  task drop: :environment do
    ElasticRecord::Task.get_models.each do |model|
      begin
        model.delete_index!
        logger.info "Dropped #{model.name} index"
      rescue => e
        if e.message =~ /IndexMissingException/
          logger.info "#{model.name} index does not exist"
        else
          raise e
        end
      end
    end
  end

  desc "Recreate index for CLASS or all models."
  task recreate: ['index:drop', 'index:create']  
end