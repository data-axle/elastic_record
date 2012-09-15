module ElasticRecord
  class Railtie < Rails::Railtie
    initializer 'elastic_record.require_log_subscriber' do
      require 'elastic_record/log_subscriber'
    end

    rake_tasks do
      load "elastic_record/tasks/index.rake"
    end
  end
end