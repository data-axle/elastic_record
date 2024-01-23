require 'helper'

class ElasticRecord::PercolatorModelTest < Minitest::Test
  def test_elastic_index
    index = WidgetQuery.elastic_index

    expected_mapping = {
      "properties"=> {
        "color"=> {"type" => "keyword" },
        "name"=> {
          "type" => "text",
          "fields" => {
            "raw" => { "type" => "keyword" }
          }
        },
        "price" => { "type" => "long" },
        "query" => { "type" => "percolator" },
        "warehouse_id" => { "type" => "keyword" },
        "widget_part" => {
          "properties" => {
            "name" => { "type" => "keyword" }
          }
        }
      }
    }

    assert_equal expected_mapping, index.get_mapping
    refute index.partial_updates
    assert_equal({}, index.settings)
  end

  def test_as_search_document
    query = WidgetQuery.new(name: 'foo', color: 'red')

    expected = {
      "query" => {
        "bool" => {
          "filter" => {
            "bool" => {
              "must" => [
                { "term" => { :name=>"foo" } },
                { "term" => { :color => "red" } }
              ]
            }
          }
        }
      }
    }

    assert_equal expected, query.as_search_document
  end

  def test_percolate_when_no_hits
    query = WidgetQuery.create(name: 'foo', color: 'red')
    should_not_hit = { name: 'bar', color: 'blue' }

    assert_empty WidgetQuery.percolate(should_not_hit)
  end

  def test_percolate_when_hits
    query = WidgetQuery.create(color: 'red')
    should_hit = { name: 'foo', color: 'red' }

    assert_equal [query], WidgetQuery.percolate(should_hit)
  end
end
