require 'helper'

class ElasticRecord::IndexTest < MiniTest::Test
  def test_copy
    copied = index.dup

    refute_equal copied.settings.object_id, index.settings.object_id
  end

  def test_doctypes
    assert_equal [Widget.doctype], index.doctypes
  end

  def test_alias_name
    assert_equal 'widgets', index.alias_name
  end

  def test_disable
    index.disable!

    assert index.disabled
  end

  def test_enable
    index.disable!
    index.enable!

    refute index.disabled
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
