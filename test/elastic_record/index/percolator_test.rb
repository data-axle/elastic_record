require 'helper'

class ElasticRecord::Index::PercolatorTest < MiniTest::Test
  def test_create_percolator
    index.disable_deferring!

    index.delete_percolator('green') if index.percolator_exists?('green')
    index.delete_percolator('blue') if index.percolator_exists?('blue')

    index.create_percolator('green', 'query' => {'match' => {'color' => 'green'}})

    assert index.percolator_exists?('green')
    refute index.percolator_exists?('blue')
  end

  def test_delete_percolator
    index.disable_deferring!

    index.create_percolator('green', 'query' => {'match' => {'color' => 'green'}})
    assert index.percolator_exists?('green')

    index.delete_percolator('green')
    refute index.percolator_exists?('green')
  end

  def test_reset_percolators
    index.disable_deferring!

    index.create_percolator('green', 'query' => {'match' => {'color' => 'green'}})
    assert index.percolator_exists?('green')

    index.reset_percolators

    refute index.percolator_exists?('green')
  end

  def test_percolate
  end

  private

    def index
      Widget.elastic_index
    end
end
