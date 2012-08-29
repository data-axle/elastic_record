module ElasticRecord
  class Task
    def self.get_models
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
      # begin
        model.elastic_index.create_and_deploy
        logger.info "Created #{model.name} index"
      # rescue => e
      #   if e.message =~ /IndexAlreadyExistsException/
      #     logger.info "#{model.name} index already exists"
      #   else
      #     raise e
      #   end
      # end
    end
  end

  desc "Drop index for CLASS or all models."
  task drop: :environment do
    ElasticRecord::Task.get_models.each do |model|
      # begin
        model.elastic_index.delete_all
        logger.info "Dropped #{model.name} index"
      # rescue => e
      #   if e.message =~ /IndexMissingException/
      #     logger.info "#{model.name} index does not exist"
      #   else
      #     raise e
      #   end
      # end
    end
  end

  desc "Recreate index for CLASS or all models."
  task reset: ['index:drop', 'index:create']
end