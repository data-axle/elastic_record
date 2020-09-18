require 'helper'

class ElasticRecord::ConfigTest < MiniTest::Test
  def test_defaults
    assert_equal '2m', ElasticRecord::Config.scroll_keep_alive
  end

  def test_models
    ElasticRecord::Config.model_names = %w(Widget)

    assert_equal [Warehouse, Widget, WidgetQuery, Project], ElasticRecord::Config.models
  end

  def test_class_for
    ElasticRecord::Config.model_names = %w(Widget)

    refute ElasticRecord::Config.class_for('not_an_index')
    assert_equal Widget, ElasticRecord::Config.class_for('widgets')
  end

  def test_servers
    with_servers ['abc.com', 'xyz.com'] do
      assert_equal ['abc.com', 'xyz.com'], ElasticRecord::Config.servers
    end

    with_servers 'abc.com,xyz.com' do
      assert_equal ['abc.com', 'xyz.com'], ElasticRecord::Config.servers
    end
  end

  private

    def with_servers(values)
      original = ElasticRecord::Config.servers
      ElasticRecord::Config.servers = values
      yield
    ensure
      ElasticRecord::Config.servers = original
    end
end
