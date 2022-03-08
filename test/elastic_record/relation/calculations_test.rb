require 'helper'

class ElasticRecord::Relation::CalculationsTest < MiniTest::Test
  def setup
    super
    Widget.destroy_all
  end

  def test_calculate
    Widget.create!(color: 'red')
    Widget.create!(color: 'red')
    Widget.create!(color: 'blue')

    assert_equal 2, Widget.elastic_relation.calculate('cardinality' => {'field' => 'color'}).value
  end
end
