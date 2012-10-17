require 'helper'

class ElasticRecord::Index::PercolatorTest < MiniTest::Spec
  def setup
    super
    index.disable_deferring!
  end

  def test_create_percolator
    index.delete(index.percolator_index_name) if index.exists?(index.percolator_index_name)

    index.create_percolator('green', 'color' => 'green')

    assert index.exists?(index.percolator_index_name)
    assert index.percolator_exists?('green')
    refute index.percolator_exists?('blue')
  end

  def test_percolator_index_name
    assert_equal 'percolate_widgets', index.percolator_index_name
  end

  private
    def index
      Widget.elastic_index
    end
end
