require 'helper'

class ElasticRecord::Relation::HitsTest < MiniTest::Test
  def test_to_ids
    red_widget = Widget.create(color: 'red')
    blue_widget = Widget.create(color: 'red')

    assert_equal [red_widget.id.to_s, blue_widget.id.to_s].to_set, Widget.elastic_relation.to_ids.to_set
  end

  def test_search_hits
    coffees = [Project.new(name: 'Latte'), Project.new(name: 'Americano')]
    Project.elastic_index.bulk_add(coffees)

    array = Project.elastic_relation.search_hits
    assert_equal %w(Latte Americano).to_set, array.map { |hit| hit["_source"]["name"] }.to_set
  end

  def test_search_results
    coffees = [Project.new(name: 'Latte'), Project.new(name: 'Americano')]
    Project.elastic_index.bulk_add(coffees)

    results = Project.elastic_relation.search_results
    %w(took timed_out _shards hits).each { |key| assert results.key?(key) }
  end
end
