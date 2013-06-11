require 'helper'

class ElasticRecord::SearchesMany::ReflectionTest < MiniTest::Spec

  def test_foreiegn_key
    assert_equal 'warehouse_id', reflection_class.new(Warehouse, :widgets, {}).foreign_key
    assert_equal 'foo_id', reflection_class.new(Warehouse, :widgets, {:foreign_key => 'foo_id' }).foreign_key
  end

  def test_klass_name
    assert_equal 'Product', reflection_class.new(Warehouse, :widgets, {class_name: 'Product'}).klass_name
    assert_equal 'Widget', reflection_class.new(Warehouse, :widgets, {}).klass_name
  end

  def test_touch_column
    assert_nil reflection_class.new(Warehouse, :widgets, {}).touch_column
    assert_equal :updated_at, reflection_class.new(Warehouse, :widgets, touch: true).touch_column
    assert_equal :my_column, reflection_class.new(Warehouse, :widgets, touch: :my_column).touch_column
  end
  
  def test_counter_cache_column
    assert_nil reflection_class.new(Warehouse, :widgets, {}).counter_cache_column
    assert_equal :widgets_count, reflection_class.new(Warehouse, :widgets, counter_cache: true).counter_cache_column
    assert_equal :my_column, reflection_class.new(Warehouse, :widgets, counter_cache: :my_column).counter_cache_column
  end

  private

    def reflection_class
      ElasticRecord::SearchesMany::Reflection
    end

end
