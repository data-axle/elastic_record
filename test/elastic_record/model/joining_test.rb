require 'helper'

class ElasticRecord::Model::JoiningTest < MiniTest::Test
  class Child < ActiveRecord::Base
    include ElasticRecord::Model
    self.elastic_index.mapping[:properties] = ::Widget.elastic_index.mapping[:properties].dup
    self.table_name = 'widgets'
    belongs_to :parent, foreign_key: :warehouse_id
  end

  class Parent < ActiveRecord::Base
    include ElasticRecord::Model
    self.elastic_index.mapping[:properties] = ::Warehouse.elastic_index.mapping[:properties].dup
    self.table_name = 'warehouses'
    child = ::ElasticRecord::Model::Joining::JoinChild.new(klass: Child, name: 'son', parent_id_accessor: ->{ warehouse_id })
    has_es_children(join_field: 'arbitrary', name: 'mom', children: child)
    elastic_index.reset
  end

  def setup
    super
    Parent.destroy_all
    Child.destroy_all
  end

  def test_elastic_index_model
    assert_equal Parent, Parent.elastic_index.model
    assert_equal Child, Child.elastic_index.model
  end

  def test_elastic_index_mapping
    expected_mapping = {
      "arbitrary" => {
        "type" => "join",
        "eager_global_ordinals" => true,
        "relations" => { "mom" => "son" }
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
    assert_equal expected_mapping, Parent.elastic_index.get_mapping.fetch('properties')
    assert_equal expected_mapping, Child.elastic_index.get_mapping.fetch('properties')
  end

  def test_elastic_index_creation
    refute Parent.elastic_index.disable_index_creation
    assert Child.elastic_index.disable_index_creation
  end

  def test_index_to_elasticsearch
    parent = Parent.new(id: 9, name: 'Queen Victoria')
    Parent.insert_all([parent.attributes])
    parent.index_to_elasticsearch

    child = Child.new(id: 10, name: 'King Edward VII', color: 'green', price: 50, parent: parent)
    Child.insert_all([child.attributes])
    child.index_to_elasticsearch

    Parent.elastic_index.refresh

    assert_equal [parent.name], Parent.filter(Parent.arelastic.queries.term('arbitrary', 'mom')).to_a.map(&:name)
    assert_equal [child.name], Child.filter(Child.arelastic.queries.term('arbitrary', 'son')).to_a.map(&:name)
    assert_equal [], Parent.filter(Parent.arelastic.queries.term('arbitrary', 'son')).to_a
    assert_equal [], Child.filter(Child.arelastic.queries.term('arbitrary', 'mom')).to_a

    assert_equal [parent.name], Parent.filter(Parent.arelastic.queries.match_all.has_child('son')).to_a.map(&:name)
    assert_equal [], Parent.filter(Parent.arelastic.queries.match_all.has_parent('mom')).to_a.map(&:name)
    assert_equal [child.name], Child.filter(Child.arelastic.queries.match_all.has_parent('mom')).to_a.map(&:name)
    assert_equal [], Child.filter(Child.arelastic.queries.match_all.has_child('son')).to_a.map(&:name)

    assert_equal [parent.name], Parent.filter(Parent.arelastic.queries.match_all).to_a.map(&:name)
    assert_equal [child.name], Child.filter(Child.arelastic.queries.match_all).to_a.map(&:name)
  end
end
