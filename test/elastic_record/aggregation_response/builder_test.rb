require 'helper'

class ElasticRecord::AggregationResponse::BuilderTest < MiniTest::Test
  def test_sub_aggregation_terms
    hash = {
      "sterms#states" => {
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
    }

    result = ElasticRecord::AggregationResponse::Builder.extract(hash)
    assert_equal ['states'], result.keys

    agg = result['states']
    assert_equal 1, agg.buckets.size

    bucket = agg.buckets.first
    assert_equal 4, bucket.doc_count
    assert_equal ['sales_per_month'], bucket.aggregations.keys
    assert_equal 2, bucket.aggregations['sales_per_month'].buckets.size
  end
end
