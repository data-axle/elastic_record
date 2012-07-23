require 'helper'

class ElasticRecord::Relation::SearchMethodsTest < MiniTest::Spec
  def test_query_with_no_queries
    expected = {"match_all" => {}}

    assert_equal expected, relation.as_elastic['query']
  end

  def test_query_with_multiple_filters
    relation.filter!('foo' => 'bar')
    relation.filter!(Widget.arelastic['faz'].in ['baz', 'fum'])
    
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

  def test_query_with_range_filter
    relation.filter!(Widget.arelastic['faz'].in 3..5)
    
    expected = {
      "constant_score" => {
        "filter" => {
          "range" => {
            "faz" => {"gte"=>3, "lte"=>5}
          }
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
    relation.filter!(Widget.arelastic['name'].prefix "mat")

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

  def test_facet_with_arelastic
    relation.facet!(Widget.arelastic.facet['popular_tags'].terms('tags'))

    expected = {
      "popular_tags" => {
        "terms" => {
          "field" => "tags"
        }
      }
    }

    assert_equal expected, relation.as_elastic['facets']
  end

  def test_facet_with_string
    relation.facet!('tags')

    expected = {
      "tags" => {
        "terms" => {
          "field" => "tags"
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

  def test_order
    relation.order! 'foo'
    relation.order! 'bar' => 'desc'

    expected = [
      'foo',
      'bar' => 'desc'
    ]

    assert_equal expected, relation.as_elastic['sort']
  end

  def test_extending_with_block
    relation.extending! do
      def foo
        'foo'
      end
    end

    assert_equal 'foo', relation.foo
  end

  def test_extending_with_module
    mod = Module.new do
      def bar
        'bar'
      end
    end

    relation.extending! mod

    assert_equal 'bar', relation.bar
  end

  private
    def relation
      @relation ||= Widget.relation
    end
end