require 'helper'

class ElasticRecord::IndexTest < MiniTest::Unit::TestCase
  def test_copy
    copied = index.dup

    refute_equal copied.settings.object_id, index.settings.object_id
    refute_equal copied.mapping.object_id, index.mapping.object_id
  end

  def test_model_name
    assert_equal 'widgets', index.alias_name
    assert_equal 'widget', index.type
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

  def test_configure
    context = nil

    index.configure do
      context = self
    end

    assert_kind_of ElasticRecord::Index::Configurator, context
  end

  private;
  
    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end