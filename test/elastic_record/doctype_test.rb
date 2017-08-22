require 'helper'

class ElasticRecord::DoctypeTest < MiniTest::Test
  def test_default_mapping
    doctype = ElasticRecord::Doctype.new('widget')

    refute_nil doctype.mapping[:properties]
  end

  def test_default_analysis
    doctype = ElasticRecord::Doctype.new('widget')

    assert_empty doctype.analysis
  end

  def test_merge_mapping
    doctype = ElasticRecord::Doctype.new('widget')
    doctype.mapping[:properties] = {
      color: { type: 'string' },
      name: { type: 'string' }
    }

    custom = { properties: { color: { type: 'integer' } }}
    doctype.mapping = custom

    expected = {
      properties: {
        color: { type: 'integer' },
        name: { type: 'string' }
      },
      _all: {
        enabled: false
      }
    }

    assert_equal expected, doctype.mapping
  end

  def test_percolator_doctype
    doctype = ElasticRecord::Doctype.percolator_doctype

    assert_equal 'queries', doctype.name
    assert_equal ElasticRecord::Doctype::PERCOLATOR_MAPPING, doctype.mapping
  end
end
