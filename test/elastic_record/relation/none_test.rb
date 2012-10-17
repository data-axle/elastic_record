require 'helper'

class ElasticRecord::Relation::NoneTest < MiniTest::Spec
  def test_none
    none = Widget.elastic_relation.none

    assert_equal 0,     none.size
    assert_equal 0,     none.count
    assert_equal [],    none.to_a
  end
end