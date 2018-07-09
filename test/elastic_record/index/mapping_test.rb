require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Test
  def test_get_mapping
    expected = {
      "widget" => {
        "properties" => {
          "color" => { "type" => "keyword" },
          "name" => {
            "type" => "text",
            "fields" => {
              "raw" => { "type" => "keyword" }
            }
          },
          "price" => {
            "type" => "long"
          },
          "warehouse_id" => { "type" => "keyword" },
          "widget_part" => {
            "properties" => {
              "name" => { "type" => "keyword" }
            }
          }
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
