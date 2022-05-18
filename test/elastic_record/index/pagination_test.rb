require "helper"

class ElasticRecord::Index::PaginationTest < MiniTest::Test
  def test_search_after
    index.index_document('bob1', { name: 'bob' })
    index.index_document('bob2', { name: 'bob' })
    index.index_document('bob3', { name: 'bob' })
    index.index_document('joe', { name: 'joe' })

    options = {
      search:     { 'query' => { query_string: { query: 'name:bob' } } },
      keep_alive: '1m',
      batch_size: 2
    }

    search_after = index.build_search_after(**options)
    assert_equal 2, search_after.request_more_hits.hits.length
    assert_equal 1, search_after.request_more_hits.hits.length
    assert_equal 3, search_after.total_hits

    without_deferring(index) do
      search_after = index.build_search_after(**options, use_point_in_time: true)
      assert_equal 2, search_after.request_more_hits.hits.length
      assert_equal 1, search_after.request_more_hits.hits.length
      assert_equal 3, search_after.total_hits
    end
  end

  private

    def index
      @index ||= Widget.elastic_index
    end
end
