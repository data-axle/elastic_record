require 'helper'

class ElasticRecord::Index::AnalyzeTest < MiniTest::Test
  def test_analyze
    tokens = Widget.elastic_index.analyze(
      'analyzer' => 'standard',
      'text'     => 'this is a test'
    )

    assert_equal %w[this is a test], tokens
  end
end
