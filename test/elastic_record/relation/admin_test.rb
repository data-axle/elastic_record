require 'helper'

class ElasticRecord::Relation::AdminTest < MiniTest::Spec
  def test_create_percolator
    Widget.elastic_index.reset_percolator

    Widget.elastic_relation.filter(color: 'green').create_percolator('green')
    Widget.elastic_relation.filter(color: 'blue').create_percolator('blue')
    widget = Widget.new(color: 'green')

    assert_equal ['green'], Widget.elastic_index.percolate(widget.as_search)
  end

  # def test_create_warmer
  #   Widget.elastic_relation.filter(color: 'green').create_warmer('green')
  #   Widget.elastic_relation.filter(color: 'blue').create_warmer('blue')
  #
  #   assert_equal ['green'], Widget.elastic_index.percolate(widget.as_search)
  # end
end