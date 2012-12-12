require 'helper'

class ElasticRecord::Index::SettingsTest < MiniTest::Spec
  def test_default_settings
    expected = {}
    assert_equal expected, ElasticRecord::Index.new(Widget).settings
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end