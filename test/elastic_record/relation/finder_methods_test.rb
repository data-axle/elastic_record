require 'helper'

module ActiveRecord
  class RecordNotFound < StandardError
  end
end

class ElasticRecord::Relation::FinderMethodsTest < MiniTest::Spec
  def setup
    super
    create_widgets
  end

  def test_find
    refute_nil Widget.elastic_relation.find('05')
    refute_nil Widget.elastic_relation.filter('color' => 'red').find('05')

    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.filter('color' => 'blue').find('05')
    end
  end

  def test_find_passed_an_array
    assert_equal 2, Widget.elastic_relation.find(['05', '10']).size
    assert_equal 2, Widget.elastic_relation.filter('color' => ['red', 'blue']).find(['05', '10']).size
    assert_equal 0, Widget.elastic_relation.find(['15', '20']).size
    assert_equal 0, Widget.elastic_relation.filter('color' => ['purple', 'gold']).find(['05', '10']).size
  end

  def test_find_passed_an_empty_args
    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.find()
    end
  end

  def test_first
    assert_equal '10', Widget.elastic_relation.order('color').first.id
    assert_equal '05', Widget.elastic_relation.order('color').filter('color' => 'red').first.id
    assert_equal '10', Widget.elastic_relation.order('color').filter('color' => 'blue').first.id
    assert_nil Widget.elastic_relation.filter('color' => 'green').first
  end

  def test_last
    assert_equal '05', Widget.elastic_relation.order('color').last.id
    assert_equal '05', Widget.elastic_relation.order('color' => 'asc').last.id
    assert_equal '10', Widget.elastic_relation.order('color' => 'desc').last.id
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
    end
end
