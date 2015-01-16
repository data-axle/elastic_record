require 'helper'

require 'active_record'

require 'mysql2'
require 'pg'

class Project < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties].update(
    name: { type: 'string', index: 'not_analyzed' }
  )
end

module ElasticRecord
  module ActiveRecordIntegration
    def setup_project_database(config)
      ActiveRecord::Tasks::DatabaseTasks.drop config
      ActiveRecord::Tasks::DatabaseTasks.create config
      ActiveRecord::Base.establish_connection config

      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migration.create_table :projects do |t|
          t.string :name, null: false
        end
      end

      Project.elastic_index.create_and_deploy if Project.elastic_index.all_names.empty?
    end

    def test_ordering
      poo_product = Project.create! name: "Poo"
      bear_product = Project.create! name: "Bear"
      Project.elastic_index.refresh

      assert_equal [bear_product, poo_product], Project.elastic_relation.order(name: 'asc')
      assert_equal [poo_product, bear_product], Project.elastic_relation.order(name: 'desc')
    end

    def test_update_callback
      project = Project.create! name: "Ideas"
      Project.elastic_index.refresh
      project.update! name: 'Terrible Stuff'
      Project.elastic_index.refresh

      assert_equal [project], Project.elastic_relation.filter(name: 'Terrible Stuff')
    end
  end
end

class ElasticRecord::Mysql2Test < MiniTest::Test
  include ElasticRecord::ActiveRecordIntegration

  def setup
    super

    setup_project_database(
      'adapter'   => 'mysql2',
      'host'      => "localhost",
      'database'  => 'elastic_record_test',
      'username'  => 'root'
    )
  end
end

class ElasticRecord::PostgresqlTest < MiniTest::Test
  include ElasticRecord::ActiveRecordIntegration

  def setup
    super

    setup_project_database(
      'adapter'   => 'postgresql',
      'encoding'  => 'unicode',
      'database'  => 'content_system_development',
      'pool'      => 5,
      'username'  => 'postgres',
      'password'  => ''
    )
  end
end
