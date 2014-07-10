require 'helper'

class ElasticRecord::SearchingTest < MiniTest::Test
  def test_elastic_search

  end

  def test_elastic_scope
    model = Widget.anon do
      elastic_scope :by_color, ->(color) { elastic_search.filter(color: color) } do
        def negative_offset
          -offset_value
        end
      end
    end

    relation = model.by_color('blue')

    assert_equal model.elastic_relation.filter(color: 'blue'), relation
    assert_equal -5, relation.offset(5).negative_offset
  end
end
