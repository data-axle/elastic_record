module ElasticRecord
  class Railtie < Rails::Railtie
    initializer 'elastic_record.require_log_subscriber' do
      require 'elastic_record/log_subscriber'
    end

    rake_tasks do
      load "elastic_record/tasks/index.rake"
    end

    # Expose database runtime to controller for logging.
    initializer "elastic_record.log_runtime" do |app|
      require "elastic_record/railties/controller_runtime"
      ActiveSupport.on_load(:action_controller) do
        include ElasticRecord::Railties::ControllerRuntime
      end
    end

    initializer "elastic_record.orm" do |app|
      ActiveSupport.on_load(:active_record) do
        require 'elastic_record/integration/active_record'
      end

      ActiveSupport.on_load(:cassandra_object) do
        require 'elastic_record/integration/cassandra_object'
      end
    end
  end
end
