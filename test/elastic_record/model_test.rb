require 'helper'

class ElasticRecord::ModelTest < MiniTest::Spec
  # def test_elastic_connection
  #   connection = Widget.elastic_connection
  # 
  #   assert_equal Widget.elastic_index.type, connection.default_type
  #   assert_equal Widget.elastic_index.alias_name, connection.default_index
  # end

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
