require 'helper'

class ElasticRecord::LuceneTest < MiniTest::Spec
  def test_escape
    assert_equal "\\\\", ElasticRecord::Lucene.escape("\\")
    assert_equal "Matt \\&& Joe", ElasticRecord::Lucene.escape("Matt && Joe")
  end

  def test_match_phrase
    assert_match_phrase nil, '', ['name']
    assert_match_phrase nil, nil, ['name']

    assert_match_phrase '(name:foo*)', 'foo', ['name']
    assert_match_phrase '(name:"foo-bar")', 'foo-bar', ['name']
    assert_match_phrase "(name:bob's*)", "bob's", ['name']
    assert_match_phrase '(name:foo* OR street:foo*)', 'foo', ['name', 'street']
    assert_match_phrase '(name:"foo bar" OR street:"foo bar") AND (name:faz* OR street:faz*)', '"foo bar" faz', ['name', 'street']
    assert_match_phrase '(street:"42 place") AND (name:bar*)', 'street:"42 place" name:bar', ['name', 'street']
  end

  def test_match_phrase_with_unmatched_quotes
    assert_match_phrase '(name:"foo bar")', '"foo bar', ['name']
  end

  def test_match_phrase_with_block
    assert_match_phrase '(name.analyzed:foo*)', 'foo', ['name'] { |f| "#{f}.analyzed" }
  end

  private

    def assert_match_phrase(expected, query, fields, &block)
      assert_equal expected, ElasticRecord::Lucene.match_phrase(query, fields, &block)
    end
end
