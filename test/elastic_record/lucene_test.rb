require 'helper'

class ElasticRecord::LuceneTest < MiniTest::Unit::TestCase
  def test_escape
    assert_equal "\\\\", ElasticRecord::Lucene.escape("\\")
    assert_equal "Matt \\&& Joe", ElasticRecord::Lucene.escape("Matt && Joe")
  end
end
