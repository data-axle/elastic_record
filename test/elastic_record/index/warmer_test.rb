require 'helper'

class ElasticRecord::Index::WarmerTest < MiniTest::Test
  def test_create_warmer
    index.delete_warmer('green') if index.warmer_exists?('green')
    refute index.warmer_exists?('green')

    index.create_warmer('green', 'query' => { "match_all" => {} })

    assert index.warmer_exists?('green')
    expected = {"types" => ["widget"], "source" => {"query" => {"match_all"=>{}}}}
    assert_equal expected, index.get_warmer('green')
  end

  private

    def index
      Widget.elastic_index
    end
end
