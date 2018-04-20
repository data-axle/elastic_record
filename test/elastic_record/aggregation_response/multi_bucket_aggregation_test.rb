require 'helper'

class ElasticRecord::AggregationResponse::MultiBucketAggregationTest < MiniTest::Test
  def test_buckets_with_sub_aggregations
    agg = sales_per_month

    bucket = agg.buckets.first
    assert_equal 4, bucket.doc_count
    assert_equal ['sales_per_month'], bucket.aggregations.keys
    assert_equal 2, bucket.aggregations['sales_per_month'].buckets.size
  end

  def test_multi_bucket_agg
    agg = sales_per_month
    assert_equal agg, agg.multi_bucket_agg
  end

  def test_flatten_buckets
    flatten_buckets = sales_per_month.flatten_buckets

    assert_equal 2, flatten_buckets.size
    row = flatten_buckets.first
    assert_equal 'WA', row[0].key
    assert_equal 1422748800000, row[1].key
  end

  private

  def sales_per_month
    ElasticRecord::AggregationResponse::MultiBucketAggregation.new 'states', {
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
  end
end
