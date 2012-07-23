require 'helper'

class ElasticRecord::SearchingTest < MiniTest::Spec
  def test_elastic_search
    
  end

  def test_elastic_scope
    model = Class.new(Widget) do
      elastic_scope :foo, -> { filter(color: 'red') }
    end

    
  end
end