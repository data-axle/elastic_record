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

  def test_filter_with_arelastic
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

  def test_filter_with_hash
    relation.filter!("prefix" => {"name" => "Jo"})
    
    expected = {
      "constant_score" => {
        "filter" => {
          "prefix" => {
            "name" => "Jo"
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
    relation.facet!(Widget.arelastic.facet['popular_tags'].histogram('field' => 'field_name', 'interval' => 100))

    expected = {
      "popular_tags" => {
        "histogram" =>
        {
          "field" => "field_name",
          "interval" => 100
        }
      }
    }

    assert_equal expected, relation.as_elastic['facets']
  end

  def test_facet_bang_with_string
    relation.facet!('tags', 'size' => 10)

    expected = {
      "tags" => {
        "terms" => {
          "field" => "tags",
          "size"  => 10
        }
      }
    }

    assert_equal expected, relation.as_elastic['facets']
  end

  def test_facet_with_string
    faceted = relation.facet('tags', 'size' => 10)

    expected = {
      "tags" => {
        "terms" => {
          "field" => "tags",
          "size"  => 10
        }
      }
    }

    assert_equal expected, faceted.as_elastic['facets']
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

  def test_select
    selectable_klass = Widget.anon do
      def self.select(values)
        @latest_select = values
        self
      end
    end

    relation = selectable_klass.elastic_relation.select 'foo'
    relation.to_a

    assert_equal ['foo'], selectable_klass.instance_variable_get('@latest_select')
  end

  def test_select_with_block
    Widget.elastic_index.bulk_add [
      Widget.new(id: 5, color: 'red'),
      Widget.new(id: 10, color: 'blue')
    ]

    records = relation.select { |record| record.id == '10' }

    assert_equal 1, records.size
    assert_equal '10', records.first.id
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
      @relation ||= Widget.elastic_relation
    end
end