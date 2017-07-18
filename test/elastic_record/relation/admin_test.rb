require 'helper'

class ElasticRecord::Relation::AdminTest < MiniTest::Test
  def test_create_percolator
    index.delete_percolator('green') if index.percolator_exists?('green')

    relation = Widget.elastic_relation.filter('color' => 'green')
    relation.create_percolator('green')

    assert_equal relation.as_elastic, index.get_percolator('green')
  end

  private

    def index
      Widget.elastic_index
    end

end
