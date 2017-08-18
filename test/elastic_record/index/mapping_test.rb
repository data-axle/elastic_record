require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Test
  # TODO
  def test_get_mapping
  end

  # TODO
  def test_update_mapping
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
