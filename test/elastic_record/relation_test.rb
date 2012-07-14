require 'helper'

class ElasticRecord::RelationTest < MiniTest::Spec
  def test_query_with_no_queries
    expected = {"match_all" => {}}

    assert_equal expected, relation.as_elastic['query']
  end

  def test_query_with_only_filters
    relation.filter!('foo' => 'bar')
    relation.filter!(relation.search['faz'].in ['baz', 'fum'])
    
    expected = {
      "constant_score" => {
        "filter" => {
          "and" => [
            {"term"   => {"foo" => "bar"}},
            {"terms"  => {"faz" => ["baz", "fum"]}}
          ]
        }
      }
    }

    assert_equal expected, relation.as_elastic['query']
  end

  def test_query_with_only_query
    relation.query!('foo')

    expected = {"query_string" => {"query" => "foo"}}

    assert_equal expected, relation.as_elastic['query']
  end

  def test_query_with_both_filter_and_query
    relation.query!('field' => {'name' => 'joe'})
    relation.filter!(relation.search['name'].prefix "mat")

    expected = {
      "filtered" => {
        "query" => {
          "field" => {
            "name"=>"joe"
          },
        },
        "filter" => {
          "prefix" => {
            "name" => "mat"
          }
        }
      }
    }

    assert_equal expected, relation.as_elastic['query']
  end

  def test_facet
    relation.facet!(relation.search.facet['popular_tags'].terms('tags'))

    expected = {
      "popular_tags" => {
        "terms" => {
          "field"=>"tags"
        }
      }
    }

    assert_equal expected, relation.as_elastic['facets']
  end

  def test_limit
    relation.limit!(5)

    expected = 5
    assert_equal expected, relation.as_elastic['size']
  end

  def test_offset
    relation.offset!(42)

    expected = 42
    assert_equal expected, relation.as_elastic['from']
  end

  def test_sort
    relation.sort! 'foo'
    relation.sort! 'bar' => 'desc'

    expected = [
      'foo',
      'bar' => 'desc'
    ]

    assert_equal expected, relation.as_elastic['sort']
  end

  private
    def relation
      @relation ||= ElasticRecord::Relation.new
    end
end