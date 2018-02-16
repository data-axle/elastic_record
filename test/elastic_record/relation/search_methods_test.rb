require 'helper'

class ElasticRecord::Relation::SearchMethodsTest < MiniTest::Test
  def test_query_with_no_queries
    expected = {"match_all" => {}}

    assert_equal expected, relation.as_elastic['query']
  end

  def test_query_with_multiple_filters
    relation.filter!('foo' => 'bar')
    relation.filter!(Widget.arelastic['faz'].in ['baz', 'fum'])

    expected = {
      "bool" => {
        "filter" => {
          "bool" => {
            "must" => [
              {"term"   => {"foo" => "bar"}},
              {"terms"  => {"faz" => ["baz", "fum"]}}
            ]
          }
        }
      }
    }

    assert_equal expected, relation.as_elastic['query']
  end

  def test_filter_with_arelastic
    relation.filter!(Widget.arelastic['faz'].in 3..5)

    expected = {
      "bool" => {
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
      "bool" => {
        "filter" => {
          "prefix" => {
            "name" => "Jo"
          }
        }
      }
    }

    assert_equal expected, relation.as_elastic['query']
  end

  def test_filter_with_negation
    scope = relation.filter.not("prefix" => {"name" => "Jo"})

    expected = {
      "bool" => {
        "filter" => {
          "bool" => {
            "must_not" => {
              "prefix" => {
                "name" => "Jo"
              }
            }
          }
        }
      }
    }

    assert_equal expected, scope.as_elastic['query']
  end

  def test_filter_with_nested
    scope = relation.filter.nested("contacts", "prefix" => {"contacts.name" => "Jo"})

    expected = {
      "bool" => {
        "filter" => {
          "nested" => {
            "path" => "contacts",
            "query" => {
              "prefix" => {
                "contacts.name" => "Jo"
              }
            }
          }
        }
      }
    }

    assert_equal expected, scope.as_elastic['query']
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
      "bool" => {
        "must" => {
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

  def test_aggregation_with_bang
    relation.aggregate!("tags" => {"terms" => {"field" => "tags"}})

    expected = {
      "tags" => {
        "terms" => {"field" => "tags"}
      }
    }

    assert_equal expected, relation.as_elastic['aggs']
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
      {'bar' => 'desc'}
    ]

    assert_equal expected, relation.as_elastic['sort']
  end

  def test_search_options
    relation.search_options! version: true

    expected = {version: true}
    assert_equal true, relation.as_elastic[:version]
  end

  def test_search_type
    relation.search_type! :count

    Widget.elastic_index.index_record Widget.new(color: 'red')

    assert_equal 1, relation.count
    assert_equal [], relation.to_ids
  end

  def test_reverse_order
    relation.order! 'foo' => {'missing' => '_last'}
    relation.order! 'bar' => 'desc'
    relation.reverse_order!

    expected = [
      {'bar' => 'asc'},
      {'foo' => {'order' => 'desc', 'missing' => '_last'}}
    ]

    assert_equal expected, relation.as_elastic['sort']
  end

  def test_select
    scope = relation.select 'foo'

    assert_equal ['foo'], scope.select_values
  end

  def test_select_with_block
    red_widget = Widget.create(color: 'red')
    blue_widget = Widget.create(color: 'blue')

    records = relation.select { |record| record.id == blue_widget.id }

    assert_equal 1, records.size
    assert_equal blue_widget, records.first
  end

  def test_includes
    warehouse = Warehouse.create! name: 'Boeing'
    widget = Widget.create! name: '747', color: 'red', warehouse: warehouse
    widget = Widget.create! name: '747', color: 'green', warehouse: warehouse

    widgets = relation.filter(color: 'red').includes(:warehouse)
    assert_equal 1, widgets.count
    assert widgets.first.association(:warehouse).loaded?

    widgets = relation.filter(color: 'red')
    assert_equal 1, widgets.count
    refute widgets.first.association(:warehouse).loaded?
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
