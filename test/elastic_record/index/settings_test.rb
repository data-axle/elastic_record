require 'helper'

class ElasticRecord::Index::SettingsTest < MiniTest::Test
  def test_default_settings
    expected = {}
    assert_equal expected, ElasticRecord::Index.new(Widget).settings
  end

  class ModelWithAnalyzers
    include TestModel

    doctype.analysis = {
      "analyzer": {
        "my_custom_analyzer": {
          "type":      "custom",
          "tokenizer": "standard"
        }
      }
    }

    elastic_index.settings = {
      "number_of_shards" => 10
    }
  end

  def test_settings
    expected = {
      "analysis" => {
        "analyzer": {
          "my_custom_analyzer": {
            "type":      "custom",
            "tokenizer": "standard"
          }
        }
      },
      "number_of_shards" => 10
    }

    assert_equal expected, ModelWithAnalyzers.elastic_index.settings
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
