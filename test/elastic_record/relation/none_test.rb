require 'helper'

class ElasticRecord::Relation::NoneTest < MiniTest::Test
  def test_none
    none = Widget.elastic_relation.none

    assert_equal 0,     none.size
    assert_equal 0,     none.count
    assert_equal [],    none.to_a
    assert_equal({},    none.aggregations)

    expected_elastic = {"not" => {"match_all" => {}}}
    assert_equal expected_elastic, none.as_elastic
  end
end
