require 'helper'

class ElasticRecord::AggregationResponse::BucketTest < MiniTest::Test
  def test_inspect
    bucket = ElasticRecord::AggregationResponse::Bucket.new('key' => 'Seattle', 'count' => 12)
    assert_equal '#<ElasticRecord::AggregationResponse::Bucket {"key"=>"Seattle", "count"=>12}>', bucket.inspect
  end
end
