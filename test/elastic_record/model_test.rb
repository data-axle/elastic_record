require 'helper'

class ElasticRecord::ModelTest < MiniTest::Spec
  def test_relation
    relation = TestModel.relation

    assert_equal TestModel, relation.klass
    assert_equal TestModel.arelastic, relation.arelastic
  end
end