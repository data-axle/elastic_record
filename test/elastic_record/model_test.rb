require 'helper'

class ElasticRecord::ModelTest < MiniTest::Test
  class InheritedModel < Widget
  end

  class TestModelAlpha
    include ElasticRecord::Model

    class << self
      def base_class
        self
      end
    end

    attr_accessor :size

    doctype.mapping = {
      properties: {
        size: { type: 'integer' }
      }
    }
  end

  class TestModelBeta
    include ElasticRecord::Model

    class << self
      def base_class
        self
      end
    end

    attr_accessor :name

    doctype.mapping = {
      properties: {
        name: { type: 'text' }
      }
    }

    def initialize(name)
      @name = name
    end
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

  def test_elastic_index_inheritence
    refute_equal Widget.elastic_index.object_id, InheritedModel.elastic_index.object_id
    refute_equal Widget.doctype.object_id, InheritedModel.doctype.object_id
  end

  def test_multimodel_index_queries_by_only_first_model_type
    custom_index = ElasticRecord::Index.new([TestModelAlpha, TestModelBeta])
    custom_index.load_from_source = true
    custom_index.disable_deferring!
    custom_index.create_and_deploy

    # assure index was created with multiple doctypes
    assert_equal [TestModelAlpha.doctype.name, TestModelBeta.doctype.name].sort, custom_index.get_mapping.keys.sort

    beta = TestModelBeta.new 'beta'
    index_resp = custom_index.index_record(beta)
    # assure model was index with its expected doctype
    assert_equal TestModelBeta.doctype.name, index_resp['_type']

    custom_index.refresh

    query_body = {
      query: {
        match: {
          name: beta.name
        }
      }
    }

    # manual search
    # finds indexed document as expected
    assert_equal beta.name, custom_index.get("_search", beta.doctype, query_body)['hits']['hits'].first['_source']['name']

    # using provided search methods
    # 'search' appears to use doctype of the first model provided when index was created
    response = custom_index.search({query: { match: beta.as_search_document } })
    assert_equal 0, response['hits']['total']
  end
end
