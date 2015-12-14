require 'helper'

class ElasticRecord::Relation::DelegationTest < MiniTest::Test
  def test_delegate_to_array
    Widget.elastic_index.delete_all
    Widget.elastic_index.index_document('5', color: 'red')

    records = []
    Widget.elastic_relation.each do |record|
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

    result = model.elastic_relation.filter('foo' => 'bar').do_it

    expected = {"query" => {"filtered" => {"filter" => {"term" => {"foo" => "bar"}}}}}
    assert_equal expected, result
  end
end
