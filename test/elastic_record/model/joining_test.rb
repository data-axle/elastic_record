require 'helper'

class ElasticRecord::Model::JoiningTest < Minitest::Test
  def setup
    super
    Mother.elastic_index.enable_deferring!
    Son.elastic_index.enable_deferring!
  end

  def teardown
    super
    Mother.elastic_index.reset_deferring!
    Son.elastic_index.reset_deferring!
  end

  def test_es_root
    assert_equal Widget, Widget.es_root
    assert_equal Mother, Mother.es_root
    assert_equal Mother, Son.es_root
  end

  def test_es_children
    assert_equal [Son], Mother.es_descendants
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

    assert_equal [mother.name], Mother.filter(Son.query(Arelastic.queries.match(:name, 'King Edward VII'))).to_a.map(&:name)
    assert_equal [son.name], Son.filter(Mother.query(Arelastic.queries.match(:name, 'Queen Victoria'))).to_a.map(&:name)
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
