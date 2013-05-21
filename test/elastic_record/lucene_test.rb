require 'helper'

class ElasticRecord::LuceneTest < MiniTest::Spec
  def test_escape
    assert_equal "\\\\", ElasticRecord::Lucene.escape("\\")
    assert_equal "Matt \\&& Joe", ElasticRecord::Lucene.escape("Matt && Joe")
  end
end
