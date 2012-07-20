require 'helper'

class ElasticRecord::Relation::FinderMethodsTest < MiniTest::Spec
  def setup
    TestModel.reset_index!
    create_widgets
  end

  def test_find
    refute_nil TestModel.relation.find(5)
    refute_nil TestModel.relation.filter('color' => 'red').find(5)
    assert_nil TestModel.relation.filter('color' => 'blue').find(5)
  end

  def test_first
    refute_nil TestModel.relation.first
    refute_nil TestModel.relation.filter('color' => 'red').first
    assert_nil TestModel.relation.filter('color' => 'green').first
  end

  private
    def create_widgets
      TestModel.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
      TestModel.elastic_connection.index({'widget' => {'color' => 'blue'}}, {index: 'widgets', type: 'widget', id: 10})
      
      TestModel.elastic_connection.refresh
    end
end