require 'helper'

class ElasticRecord::Index::ManageTest < MiniTest::Spec
  def setup
    super

    index.delete_all
  end
  
  def test_create
    assert !index.exists?('foo')

    index.create 'foo'

    assert index.exists?('foo')
  end

  def test_exists
    index.create 'foo'

    assert index.exists?('foo')
    assert !index.exists?('bar')
  end

  def test_deploy
    index.create 'foo'
    
    assert_nil index.deployed_name
    index.deploy 'foo'

    assert_equal 'widgets_foo', index.deployed_name
  end

  private
    def index
      @index ||= Widget.elastic_index
    end
end