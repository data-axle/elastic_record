module ElasticRecord
  class Railtie < Rails::Railtie
    rake_tasks { load "elastic_record/tasks/index.rake" }
  end
end