require 'helper'

class ElasticRecord::AggregationResponse::MultiBucketAggregationTest < MiniTest::Test
  def test_single
    agg = ElasticRecord::AggregationResponse::SingleValueAggregation.new 'average_price', 'value' => 4

    assert_equal 4, agg.value
  end
end
