require 'helper'

class ElasticRecord::Index::MappingTypeTest < MiniTest::Test
  def test_default
    assert_equal '_doc', index.mapping_type
  end

  def test_writer
    index.mapping_type = 'widget'
    assert_equal 'widget', index.mapping_type
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
