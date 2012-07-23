require 'helper'

class ElasticRecord::Relation::MergingTest < MiniTest::Spec
  def test_merge_single_values
    relation = Widget.relation.limit(5)
    other = Widget.relation.limit(10)

    relation.merge! other

    assert_equal 10, relation.limit_value
  end

  def test_merge_multi_values
    relation = Widget.relation.filter(color: 'green')
    other = Widget.relation.filter(weight: 1.0)

    relation.merge! other

    assert_equal [{color: 'green'}, {weight: 1.0}], relation.filter_values
  end
end