require 'helper'

class ElasticRecord::Model::JoiningTest < MiniTest::Test
  class Son < ActiveRecord::Base
    include ElasticRecord::Model
    self.elastic_index.mapping[:properties] = ::Widget.elastic_index.mapping[:properties].dup
    self.table_name = 'widgets'
    belongs_to :mother, foreign_key: :warehouse_id
  end

  class Mother < ActiveRecord::Base
    include ElasticRecord::Model
    self.elastic_index.mapping[:properties] = ::Warehouse.elastic_index.mapping[:properties].dup
    self.table_name = 'warehouses'
    son = ::ElasticRecord::Model::Joining::JoinChild.new(klass: Son, parent_id_accessor: ->{ warehouse_id })
    has_es_children(join_field: 'arbitrary', children: son)
    elastic_index.reset
  end

  def setup
    super
    Mother.destroy_all
    Son.destroy_all
  end

  def test_elastic_index_model
    assert_equal Mother, Mother.elastic_index.model
    assert_equal Son, Son.elastic_index.model
  end

  def test_elastic_index_mapping
    expected_mapping = {
      "arbitrary" => {
        "type" => "join",
        "eager_global_ordinals" => true,
        "relations" => { "mother" => "son" }
      },
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
    assert_equal expected_mapping, Mother.elastic_index.get_mapping.fetch('properties')
    assert_equal expected_mapping, Son.elastic_index.get_mapping.fetch('properties')
  end

  def test_elastic_index_creation
    refute Mother.elastic_index.disable_index_creation
    assert Son.elastic_index.disable_index_creation
  end

  def test_index_to_elasticsearch
    mother = Mother.new(id: 9, name: 'Queen Victoria')
    Mother.insert_all([mother.attributes])
    mother.index_to_elasticsearch

    son = Son.new(id: 10, name: 'King Edward VII', color: 'green', price: 50, mother: mother)
    Son.insert_all([son.attributes])
    son.index_to_elasticsearch

    Mother.elastic_index.refresh

    assert_equal [mother.name], Mother.filter(Mother.arelastic.queries.term('arbitrary', 'mother')).to_a.map(&:name)
    assert_equal [son.name], Son.filter(Son.arelastic.queries.term('arbitrary', 'son')).to_a.map(&:name)
    assert_equal [], Mother.filter(Mother.arelastic.queries.term('arbitrary', 'son')).to_a
    assert_equal [], Son.filter(Son.arelastic.queries.term('arbitrary', 'mother')).to_a

    assert_equal [mother.name], Mother.filter(Mother.arelastic.queries.match_all.has_child('son')).to_a.map(&:name)
    assert_equal [], Mother.filter(Mother.arelastic.queries.match_all.has_parent('mother')).to_a.map(&:name)
    assert_equal [son.name], Son.filter(Son.arelastic.queries.match_all.has_parent('mother')).to_a.map(&:name)
    assert_equal [], Son.filter(Son.arelastic.queries.match_all.has_child('son')).to_a.map(&:name)

    assert_equal [mother.name], Mother.filter(Mother.arelastic.queries.match_all).to_a.map(&:name)
    assert_equal [son.name], Son.filter(Son.arelastic.queries.match_all).to_a.map(&:name)
  end

  def test_bulk_insert_with_parent_join
    mother = Mother.new(id: 9, name: 'Queen Victoria')
    Mother.insert_all([mother.attributes])

    son = Son.new(id: 10, name: 'King Edward VII', mother: mother)
    Son.insert_all([son.attributes])

    index = Mother.elastic_index
    assert_nil index.current_bulk_batch

    index.bulk do
      index.index_record(mother)
      index.index_record(son)

      expected = [
        {index: {_index: index.alias_name, _id: 9}},
        {"name" => "Queen Victoria", "arbitrary" => {"name" => "mother"}},
        {index: {_index: index.alias_name, _id: 10, routing: "9"}},
        {"name" => "King Edward VII", "warehouse_id" => "9", "arbitrary" => {"name" => "son", "parent" => "9"}}

      ]

      assert_equal expected, index.current_bulk_batch
    end

    assert_nil index.current_bulk_batch
  end
end
