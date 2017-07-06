require 'helper'

class ElasticRecord::ActiveRecordTest < MiniTest::Test
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
