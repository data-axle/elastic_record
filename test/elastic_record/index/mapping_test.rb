require 'helper'

class ElasticRecord::Index::MappingTest < MiniTest::Spec
  def test_default_mapping
    mapping = index.mapping

    refute_nil mapping[:_source]
    refute_nil mapping[:properties]
  end

  private
    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end