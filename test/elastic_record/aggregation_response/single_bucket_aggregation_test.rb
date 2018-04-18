require 'helper'

class ElasticRecord::AggregationResponse::SingleBucketAggregationTest < MiniTest::Test
  def test_single
    agg = ElasticRecord::AggregationResponse::SingleBucketAggregation.new 'resellers', {
      'doc_count' => 0,
      'min#min_price' => {
        'value' => 350
      }
    }

    assert_equal 0, agg.doc_count
    assert_equal 350, agg.aggregations['min_price'].value
  end
end
