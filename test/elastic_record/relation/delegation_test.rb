require 'helper'

class ElasticRecord::Relation::DelegationTest < MiniTest::Spec
  def setup
    TestModel.reset_index!
  end

  def test_delegate_to_array
    TestModel.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
    TestModel.elastic_connection.refresh
    
    records = []
    TestModel.relation.each do |record|
      records << record
    end

    assert_equal 1, records.size
  end

  def test_delegate_to_klass
    
  end
end