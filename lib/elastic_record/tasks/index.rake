module ElasticRecord
  class Task
    def self.get_models
      if class_name = ENV['CLASS']
        [class_name.camelize.constantize]
      else
        ElasticRecord::Config.models
      end
    end
  end
end

namespace :index do
  desc "Create index for CLASS or all models."
  task create: :environment do
    ElasticRecord::Task.get_models.each do |model|
      index = model.elastic_index
      index_name = index.create_and_deploy
      puts "Created #{model.name} index (#{index_name})"
    end
  end

  desc "Drop index for CLASS or all models."
  task drop: :environment do
    ElasticRecord::Task.get_models.each do |model|
      index = model.elastic_index
      index.delete_all
      puts "Dropped #{model.name} index"
    end
  end

  desc "Recreate index for CLASS or all models."
  task reset: ['index:drop', 'index:create']

  desc "Create index for all models that don't already have one"
  task create_missing: :environment do
    ElasticRecord::Task.get_models.each do |model|
      index = model.elastic_index
      if (all_names = index.all_names).empty?
        index_name = index.create_and_deploy
        puts "Created #{model.name} index (#{index_name})"
      else
        puts "#{model.name} already has an index (#{all_names.last})"
      end
    end
  end

  task update_mapping: :environment do
    ElasticRecord::Task.get_models.each do |model|
      model.elastic_index.create_and_deploy
      puts "Updated mapping for #{model.name}"
    end
  end

  desc "Add records to index. Deploys a new index by default, or specify INDEX"
  task build: :environment do
    ElasticRecord::Task.get_models.each do |model|
      puts "Building #{model.name} index."

      if ENV['INDEX']
        index_name = ENV['INDEX']
      else
        puts "  Creating index..."
        index_name = model.elastic_index.create
      end

      if model.elastic_index.load_from_source
        puts "  Reindexing into #{index_name} [skipped]"
      else
        puts "  Reindexing into #{index_name}"
        model.find_in_batches(batch_size: 100) do |records|
          model.elastic_index.bulk_add(records, index_name: index_name)
        end
      end

      puts "  Deploying index..."
      model.elastic_index.deploy(index_name)

      puts "  Done."
    end
  end
end
