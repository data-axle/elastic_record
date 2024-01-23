require 'helper'

class ElasticRecord::Index::MappingTypeTest < Minitest::Test
  def test_default
    assert_equal '_doc', index.mapping_type
  end

  def test_writer
    index.mapping_type = 'widget'
    assert_equal 'widget', index.mapping_type
    index.mapping_type = '_doc'
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
