require 'helper'

class ElasticRecord::ModelTest < MiniTest::Spec
  def test_relation
    relation = Widget.relation

    assert_equal Widget, relation.klass
    assert_equal Widget.arelastic, relation.arelastic
  end
end