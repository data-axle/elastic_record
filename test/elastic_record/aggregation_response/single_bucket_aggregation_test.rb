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

  def test_multi_bucket_agg
    agg = ElasticRecord::AggregationResponse::SingleBucketAggregation.new 'resellers', {
      'doc_count' => 0,
      'sterms#best_sellers' => {
        'buckets' => [
          {'key' => 'elmo', 'doc_count' => 3}
        ]
      }
    }

    assert_equal 'best_sellers', agg.multi_bucket_agg.name
  end
end
