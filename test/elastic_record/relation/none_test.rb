require 'helper'

class ElasticRecord::Relation::NoneTest < MiniTest::Spec
  def test_none
    none = Widget.elastic_relation.none

    assert_equal 0,     none.size
    assert_equal 0,     none.count
    assert_equal [],    none.to_a

    expected_elastic = {"not" => {"match_all" => {}}}
    assert_equal expected_elastic, none.as_elastic
  end
end