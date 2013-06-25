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

require 'elastic_record/integration/active_record'
class Project < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties].update(
    name: { type: 'string', index: 'not_analyzed' }
  )
end

class ElasticRecord::ActiveRecordTest < MiniTest::Spec
  def test_load_elastic_record_hits
    poo_product = Project.create! name: "Poo"
    bear_product = Project.create! name: "Bear"

    assert_equal [poo_product, bear_product], Project.load_elastic_record_hits([poo_product.id, bear_product.id])
    assert_equal [bear_product, poo_product], Project.load_elastic_record_hits([bear_product.id, poo_product.id])
  end
end