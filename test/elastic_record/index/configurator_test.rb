require 'helper'

class ElasticRecord::Index::ConfiguratorTest < MiniTest::Test
  def test_property
    configurator.property :am_i_cool, type: "boolean"

    expected = {type: "boolean"}
    assert_equal expected, configurator.index.mapping[:properties][:am_i_cool]
  end

  private
    def configurator
      @configurator ||= begin
        index = ElasticRecord::Index.new(Widget)
        ElasticRecord::Index::Configurator.new(index)
      end
    end
end