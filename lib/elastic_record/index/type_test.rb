require 'helper'

class ElasticRecord::Index::TypeTest < MiniTest::Test
  def test_default
    assert_equal '_doc', index.type
  end

  def test_writer
    index.type = 'widget'
    assert_equal 'widget', index.type
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
