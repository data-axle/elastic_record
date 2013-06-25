require 'helper'

class ElasticRecord::ModelTest < MiniTest::Unit::TestCase
  class InheritedModel < Widget
  end

  def test_elastic_connection
    connection = Widget.elastic_connection

    assert_equal [ElasticRecord::Config.servers], connection.servers
    assert_equal ElasticRecord::Config.connection_options, connection.options
  end

  def test_elastic_relation
    relation = Widget.elastic_relation

    assert_equal Widget, relation.klass
    assert_equal Widget.arelastic, relation.arelastic
  end

  def test_elastic_index
    index = Widget.elastic_index

    assert_equal Widget, index.model
  end

  def test_elastic_index_inheritence
    refute_equal Widget.elastic_index.object_id, InheritedModel.elastic_index.object_id
  end
end
