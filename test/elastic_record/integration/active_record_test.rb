require 'helper'

require 'active_record'
require 'mysql2'

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: "localhost",
    database: "elastic_record_test",
    username: "root"
  )

  `mysqladmin -u root -f drop elastic_record_test`
  `mysqladmin -u root create elastic_record_test`

  ActiveRecord::Migration.create_table :projects do |t|
    t.string :name, null: false
  end
end

class Project < ActiveRecord::Base
  include ElasticRecord::Model
  include ElasticRecord::Callbacks

  self.elastic_index.mapping[:properties].update(
    name: { type: 'string', index: 'not_analyzed' }
  )
end

class ElasticRecord::ActiveRecordTest < MiniTest::Unit::TestCase
  def setup
    super
    Project.elastic_index.create_and_deploy if Project.elastic_index.all_names.empty?
  end

  def test_ordering
    poo_product = Project.create! name: "Poo"
    bear_product = Project.create! name: "Bear"
    Project.elastic_index.refresh

    assert_equal [bear_product, poo_product], Project.elastic_relation.order(name: 'asc')
    assert_equal [poo_product, bear_product], Project.elastic_relation.order(name: 'desc')
  end
end