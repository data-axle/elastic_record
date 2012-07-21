require 'helper'

class ElasticRecord::Relation::DelegationTest < MiniTest::Spec
  def setup
    Widget.reset_index!
  end

  def test_delegate_to_array
    Widget.elastic_connection.index({'widget' => {'color' => 'red'}}, {index: 'widgets', type: 'widget', id: 5})
    Widget.elastic_connection.refresh
    
    records = []
    Widget.relation.each do |record|
      records << record
    end

    assert_equal 1, records.size
  end

  def test_delegate_to_klass
    model = Class.new(Widget) do
      def self.do_it
        elastic_search.as_elastic
      end
    end

    result = model.relation.filter('foo' => 'bar').do_it

    expected = {"query"=>{"constant_score"=>{"filter"=>{"term"=>{"foo"=>"bar"}}}}}
    assert_equal expected, result 
  end
end