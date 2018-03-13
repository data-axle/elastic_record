require 'helper'

class ElasticRecord::PercolatorModelTest < MiniTest::Test
  def test_elastic_index
    assert_equal WidgetQuery.doctype, index.doctype
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

  private

    def index
      @index ||= WidgetQuery.elastic_index
    end
end
