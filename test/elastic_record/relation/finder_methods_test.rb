require 'helper'

class ElasticRecord::Relation::FinderMethodsTest < Minitest::Test
  def setup
    super
    @red_widget = Widget.create(color: 'red')
    @blue_widget = Widget.create(color: 'blue')
  end

  def test_find
    refute_nil Widget.elastic_relation.find(@red_widget.id)
    refute_nil Widget.elastic_relation.filter('color' => 'red').find(@red_widget.id)

    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.filter('color' => 'blue').find(@red_widget.id)
    end
  end

  def test_find_exceed_default_limit
    widgets = ('a'..'l').map {|color| Widget.create(color: color) }
    assert_equal 12, Widget.elastic_relation.find(widgets.map(&:id)).size
    assert_equal 11, Widget.elastic_relation.limit(11).find(widgets.map(&:id)).size
  end

  def test_find_passed_an_array
    assert_equal 2, Widget.elastic_relation.find([@red_widget.id, @blue_widget.id]).size
    assert_equal 1, Widget.elastic_relation.find([@red_widget.id]).size
    assert_equal 2, Widget.elastic_relation.filter('color' => ['red', 'blue']).find([@red_widget.id, @blue_widget.id]).size
    assert_equal 0, Widget.elastic_relation.filter('color' => ['purple', 'gold']).find([@red_widget.id, @blue_widget.id]).size
  end

  def test_find_passed_an_empty_args
    assert_equal [], Widget.elastic_relation.find([])
    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.find
    end
  end

  def test_first
    assert_equal 'blue', Widget.elastic_relation.order('color').first.color
    assert_equal 'red', Widget.elastic_relation.order('color').filter('color' => 'red').first.color
    assert_equal 'blue', Widget.elastic_relation.order('color').filter('color' => 'blue').first.color
    assert_nil Widget.elastic_relation.filter('color' => 'green').first
  end

  def test_first_with_bang
    assert_equal 'blue', Widget.elastic_relation.order('color').first!.color
    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.filter('color' => 'green').first!
    end
  end

  def test_last
    assert_equal 'red', Widget.elastic_relation.order('color').last.color
    assert_equal 'red', Widget.elastic_relation.order('color' => 'asc').last.color
    assert_equal 'blue', Widget.elastic_relation.order('color' => 'desc').last.color
  end

  def test_all
    assert_equal 2, Widget.elastic_relation.all.size
    assert_equal 1, Widget.elastic_relation.filter('color' => 'red').all.size
  end

  def test_find_by
    assert_equal 'red', Widget.elastic_relation.find_by(color: 'red').color
    assert_equal 'red', Widget.elastic_relation.find_by!(color: 'red').color
    assert_raises ActiveRecord::RecordNotFound do
      Widget.elastic_relation.find_by!(color: 'green')
    end
  end
end
