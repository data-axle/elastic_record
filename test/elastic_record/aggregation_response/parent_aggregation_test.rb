require 'helper'

class ElasticRecord::AggregationResponse::ParentAggregationTest < Minitest::Test
  def test_parent_aggregation_response_for_fill_count
    agg = ElasticRecord::AggregationResponse::ParentAggregation.new 'fill_count', {
      "doc_count" => 10,
      "filter#fill_count" => {
        "doc_count" => 7
      }
    }

    assert_equal %w(fill_count), agg.aggregations.keys.sort
    assert_equal 7, agg.doc_count

    refute agg.respond_to?(:value)
    refute agg.respond_to?(:buckets)
  end

  def test_parent_aggregation_response_for_value_count
    agg = ElasticRecord::AggregationResponse::ParentAggregation.new 'value_count', {
      "doc_count" => 10,
      "value_count#value_count" => {
        "value" => 7
      }
    }

    assert_equal %w(value_count), agg.aggregations.keys.sort
    assert_equal 10, agg.doc_count
    assert_equal 7, agg.value

    refute agg.respond_to?(:buckets)
  end

  def test_parent_aggregation_response_for_terms
    agg = ElasticRecord::AggregationResponse::ParentAggregation.new 'states', {
      "sterms#states" => {
        "doc_count" => 9,
        "buckets" => [
          {
            "key" => "WA",
            "doc_count" => 4,
          },
          {
            "key" => "OR",
            "doc_count" => 6,
          }
        ]
      }
    }

    assert_equal %w(states), agg.aggregations.keys.sort
    assert_equal 9, agg.doc_count

    assert_equal 2, agg.buckets.size
    assert_equal 4, agg.buckets.first.doc_count
    assert_equal 'WA', agg.buckets.first.key

    refute agg.respond_to?(:value)
  end
end
