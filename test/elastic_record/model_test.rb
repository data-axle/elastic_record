require 'helper'

class ElasticRecord::ModelTest < MiniTest::Test
  class InheritedModel < Widget
  end

  def test_elastic_connection
    connection = Widget.elastic_connection

    assert_equal ElasticRecord::Config.servers, connection.servers
    assert_equal ElasticRecord::Config.connection_options.symbolize_keys, connection.options
  end

  def test_elastic_index
    index = Widget.elastic_index

    assert_equal Widget, index.model
  end

  def test_elastic_index_inheritance
    refute_equal Widget.elastic_index.object_id, InheritedModel.elastic_index.object_id
    assert_equal Widget.elastic_index.mapping_type, InheritedModel.elastic_index.mapping_type
    assert_equal 'widgets', InheritedModel.elastic_index.alias_name
    assert_equal InheritedModel, InheritedModel.elastic_index.model
    assert_equal '_doc', InheritedModel.elastic_index.mapping_type
  end

  def test_index_to_elasticsearch
    project = Project.new(name: 'scorpio')
    project.index_to_elasticsearch

    assert_equal [project.name], Project.filter(name: 'scorpio').map(&:name)
  end
end
