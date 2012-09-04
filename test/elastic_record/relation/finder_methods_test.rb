require 'helper'

class ElasticRecord::Relation::FinderMethodsTest < MiniTest::Spec
  def setup
    Widget.reset_index!
    create_widgets
  end

  def test_find
    refute_nil Widget.elastic_relation.find('05')
    refute_nil Widget.elastic_relation.filter('color' => 'red').find('05')
    assert_nil Widget.elastic_relation.filter('color' => 'blue').find('05')
  end

  def test_first
    assert_equal '05', Widget.elastic_relation.first.id
    assert_equal '05', Widget.elastic_relation.filter('color' => 'red').first.id
    assert_equal '10', Widget.elastic_relation.filter('color' => 'blue').first.id
    assert_nil Widget.elastic_relation.filter('color' => 'green').first
  end

  def test_last
    assert_equal '10', Widget.elastic_relation.last.id
    assert_equal '05', Widget.elastic_relation.filter('color' => 'red').last.id
    assert_equal '10', Widget.elastic_relation.filter('color' => 'blue').last.id
    assert_nil Widget.elastic_relation.filter('color' => 'green').last
  end

  def test_all
    assert_equal 2, Widget.elastic_relation.all.size
    assert_equal 1, Widget.elastic_relation.filter('color' => 'red').all.size
  end

  private

    def create_widgets
      Widget.elastic_index.bulk_add [
        Widget.new(color: 'red', id: '05'),
        Widget.new(color: 'blue', id: '10'),
      ]
      
      Widget.elastic_index.refresh
    end
end