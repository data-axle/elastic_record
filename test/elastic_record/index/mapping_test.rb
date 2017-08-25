require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Test
  def test_get_mapping
    expected = {
      "widget" => {
        "_all" => { "enabled" => false },
        "properties" => {
          "color" => { "type" => "keyword" },
          "name" => {
            "type" => "keyword",
            "fields" => { "analyzed" => { "type" => "text" } }
          },
          "warehouse_id" => { "type" => "keyword" }
        }
      }
    }

    assert_equal expected, index.get_mapping
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
