require 'helper'

class ElasticRecord::AggregationResponse::SingleValueAggregationTest < MiniTest::Test
  def test_value
    agg = ElasticRecord::AggregationResponse::SingleValueAggregation.new 'average_price', 'value' => 4

    assert_equal 4, agg.value
  end
end
