require 'helper'

class ElasticRecord::Index::PercolatorTest < MiniTest::Spec
  def test_create_percolator
    index.delete_percolator('green') if index.percolator_exists?('green')
    index.delete_percolator('blue') if index.percolator_exists?('blue')

    index.create_percolator('green', 'color' => 'green')

    assert index.percolator_exists?('green')
    refute index.percolator_exists?('blue')
  end

  def test_delete_percolator
    index.create_percolator('green', 'color' => 'green')
    assert index.percolator_exists?('green')

    index.delete_percolator('green')
    refute index.percolator_exists?('green')
  end

  def test_percolate
  end

  private
    def index
      Widget.elastic_index
    end
end
