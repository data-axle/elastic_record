require 'helper'

class ElasticRecord::ModelTest < MiniTest::Spec
  def test_elastic_relation
    relation = Widget.elastic_relation

    assert_equal Widget, relation.klass
    assert_equal Widget.arelastic, relation.arelastic
  end

  def test_elastic_index
    index = Widget.elastic_index

    assert_equal Widget, index.model
  end
end
