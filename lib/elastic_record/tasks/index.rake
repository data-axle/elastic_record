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

      if index.has_percolator
        index_name = index.create_percolator_index
        puts "Created #{model.name} percolator index (#{index_name})"
      end
    end
  end

  desc "Drop index for CLASS or all models."
  task drop: :environment do
    ElasticRecord::Task.get_models.each do |model|
      index = model.elastic_index
      index.delete_all
      puts "Dropped #{model.name} index"

      if index.has_percolator
        index.delete_percolator_index
        puts "Dropped #{model.name} percolator index (#{index.percolator_name})"
      end
    end
  end

  desc "Recreate index for CLASS or all models."
  task reset: ['index:drop', 'index:create']

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

      puts "  Reindexing into #{index_name}"
      model.find_in_batches(batch_size: 100) do |records|
        model.elastic_index.bulk_add(records, index_name: index_name)
      end

      puts "  Deploying index..."
      model.elastic_index.deploy(index_name)

      puts "  Done."
    end
  end
end
