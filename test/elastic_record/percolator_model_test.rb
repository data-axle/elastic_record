require 'helper'

class ElasticRecord::PercolatorModelTest < MiniTest::Test
  def test_doctype
    assert_equal ElasticRecord::Doctype.percolator_doctype, WidgetQuery.doctype
  end

  def as_search
  end

  def test_percolate
  end
end
