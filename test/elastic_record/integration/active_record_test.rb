require 'helper'

class ElasticRecord::ActiveRecordTest < Minitest::Test
  def test_ordering
    poo_product = Warehouse.create! name: "Poo"
    bear_product = Warehouse.create! name: "Bear"

    assert_equal [bear_product, poo_product], Warehouse.elastic_relation.order(name: 'asc')
    assert_equal [poo_product, bear_product], Warehouse.elastic_relation.order(name: 'desc')
  end

  def test_update_callback
    project = Warehouse.create! name: "Ideas"
    project.update! name: 'Terrible Stuff'

    assert_equal [project], Warehouse.elastic_relation.filter(name: 'Terrible Stuff')
  end
end
