require 'helper'

class ElasticRecord::LuceneTest < MiniTest::Spec
  def test_escape
    assert_equal "\\\\", ElasticRecord::Lucene.escape("\\")
    assert_equal "Matt \\&& Joe", ElasticRecord::Lucene.escape("Matt && Joe")
  end

  def test_smart_search
    assert_smart_escape nil, '', ['name']
    assert_smart_escape nil, nil, ['name']

    assert_smart_escape '(name:foo*)', 'foo', ['name']
    assert_smart_escape "(name:bob's*)", "bob's", ['name']
    assert_smart_escape '(name.analyzed:foo*)', 'foo', ['name'] { |f| "#{f}.analyzed" }
    assert_smart_escape '(name:foo* OR street:foo*)', 'foo', ['name', 'street']
    assert_smart_escape '(name:"foo bar" OR street:"foo bar") AND (name:faz* OR street:faz*)', '"foo bar" faz', ['name', 'street']
    assert_smart_escape '(street:"42 place") AND (name:bar*)', 'street:"42 place" name:bar', ['name', 'street']
  end

  private
    def assert_smart_escape(expected, query, fields, &block)
      assert_equal expected, ElasticRecord::Lucene.smart_query(query, fields, &block)
    end
end