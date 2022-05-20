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

  def test_invalid_point_in_time_error
    search_after = index.build_search_after(
      keep_alive:       '1m',
      point_in_time_id: 'foobar',
      search:           { 'query' => { query_string: { query: 'name:bob' } } },
      batch_size:       2,
    )
    assert_raises ElasticRecord::InvalidPointInTimeError do
      search_after.request_more_hits
    end
  end

  def test_each_slice
    10.times { |i| index.index_document("bob#{i}", { color: 'red' }) }
    batches = []

    search_after = index.build_search_after(
      search:            { 'query' => { query_string: { query: 'color:red' } } },
      batch_size:        2,
      use_point_in_time: true
    )
    search_after.each_slice do |slice|
      batches << slice
    end
    assert_equal 5, batches.size

    assert_raises ElasticRecord::ExpiredPointInTime do
      search_after.request_more_hits
    end
  end

  def test_each_slice_with_few_records
    index.index_document("joe1", { color: 'pink' })
    batches = []

    search_after = index.build_search_after(
      search:            { 'query' => { query_string: { query: 'color:pink' } } },
      batch_size:        4,
      use_point_in_time: true
    )
    search_after.each_slice do |slice|
      batches << slice
    end
    assert_equal 1, batches.size
  end

  private

    def index
      @index ||= Widget.elastic_index
    end
end
