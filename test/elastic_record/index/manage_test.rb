require 'helper'

class ElasticRecord::Index::ManageTest < MiniTest::Spec
  def setup
    super
    index.delete('foo') if index.exists?('foo')    
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

  def test_alias_to
    # p index.alias_to
  end

  private
    def index
      @index ||= Widget.elastic_index
    end
end