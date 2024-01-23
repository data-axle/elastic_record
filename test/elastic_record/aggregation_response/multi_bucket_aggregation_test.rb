require 'helper'

class ElasticRecord::AggregationResponse::MultiBucketAggregationTest < Minitest::Test
  def test_multi_bucket_aggregation_response
    agg = ElasticRecord::AggregationResponse::MultiBucketAggregation.new 'states', {
      "buckets" => [
        {
          "key" => "WA",
          "doc_count" => 4,
          "lterms#sales_per_month" => {
            "buckets" => [
              {
                "key_as_string" => "2015-02-01",
                "key" => 1422748800000,
                "doc_count" => 3
              },
              {
                "key_as_string" => "2015-03-01",
                "key" => 1425168000000,
                "doc_count" => 1
              }
            ]
          }
        }
      ]
    }

    bucket = agg.buckets.first
    assert_equal 4, bucket.doc_count
    assert_equal ['sales_per_month'], bucket.aggregations.keys
    assert_equal 2, bucket.aggregations['sales_per_month'].buckets.size
  end
end
