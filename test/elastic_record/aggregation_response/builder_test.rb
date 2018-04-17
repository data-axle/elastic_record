require 'helper'

class ElasticRecord::AggregationResponse::BuilderTest < MiniTest::Test
  def test_foo
    hash = {
      "sterms#states" => {
        "doc_count_error_upper_bound" => 0,
        "sum_other_doc_count" => 0,
        "buckets" => [
          {
            "key" => "WA",
            "doc_count" => 2,
            "sterms#names" => {
              "doc_count_error_upper_bound" => 0,
              "sum_other_doc_count" => 0,
              "buckets" => [
                {
                  "key" => "Acme",
                  "doc_count" => 1
                },
                {
                  "key" => "Gotime Hq",
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
    assert_equal 2, bucket.doc_count
    assert_equal ['names'], bucket.aggregations.keys
  end
end
