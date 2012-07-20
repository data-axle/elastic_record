require 'helper'

class ElasticRecord::Relation::FinderMethodsTest < MiniTest::Spec
  def setup
    TestModel.reset_index!
    create_widgets
  end

  def test_find
    refute_nil TestModel.relation.find('05')
    refute_nil TestModel.relation.filter('color' => 'red').find('05')
    assert_nil TestModel.relation.filter('color' => 'blue').find('05')
  end

  def test_first
    assert_equal '05', TestModel.relation.first.id
    assert_equal '05', TestModel.relation.filter('color' => 'red').first.id
    assert_equal '10', TestModel.relation.filter('color' => 'blue').first.id
    assert_nil TestModel.relation.filter('color' => 'green').first
  end

  def test_last
    assert_equal '10', TestModel.relation.last.id
    assert_equal '05', TestModel.relation.filter('color' => 'red').last.id
    assert_equal '10', TestModel.relation.filter('color' => 'blue').last.id
    assert_nil TestModel.relation.filter('color' => 'green').last
  end

  def test_all
    assert_equal 2, TestModel.relation.all.size
    assert_equal 1, TestModel.relation.filter('color' => 'red').all.size
  end

  private

    def create_widgets
      TestModel.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: '05'})
      TestModel.elastic_connection.index({'widget' => {'color' => 'blue'}}, {index: 'widgets', type: 'widget', id: '10'})
      
      TestModel.elastic_connection.refresh
    end
end