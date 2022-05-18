require "helper"

class ElasticRecord::Index::PaginationTest < MiniTest::Test
  def test_build_scroll_enumerator
    index.index_document('bob', { name: 'bob' })
    index.index_document('joe', { name: 'joe' })

    scroll_enumerator = index.build_scroll_enumerator(search: {'query' => {query_string: {query: 'name:bob'}}})

    assert_equal 1, scroll_enumerator.total_hits
    assert_equal 1, scroll_enumerator.request_more_ids.size
  end

  def test_expired_scroll_error
    index.index_document('bob', { name: 'bob' })
    index.index_document('bobs', { name: 'bob' })

    scroll_enumerator = index.build_scroll_enumerator(
      search: { 'query' => { query_string: { query: 'name:bob' } } },
      batch_size: 1,
      keep_alive: '1ms'
    )

    scroll_enumerator.request_more_hits
    index.delete_scroll(scroll_enumerator.scroll_id)
    assert_raises ElasticRecord::ExpiredScrollError do
      scroll_enumerator.request_more_hits
    end
  end

  def test_each_slice
    10.times { |i| index.index_document("bob#{i}", { color: 'red' }) }
    batches = []

    scroll_enumerator = index.build_scroll_enumerator(search: {'query' => {query_string: {query: 'color:red'}}}, batch_size: 1)

    scroll_enumerator.each_slice do |slice|
      batches << slice
    end

    assert_equal 10, batches.size

    # Assert context was removed
    assert_raises ElasticRecord::ExpiredScrollError do
      scroll_enumerator.request_more_hits
    end
  end

  def test_invalid_scroll_error
    assert_raises ElasticRecord::InvalidScrollError do
      index.scroll('invalid', '1m')
    end
  end

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

    index.disable_deferring!
    search_after = index.build_search_after(**options, use_point_in_time: true)
    assert_equal 2, search_after.request_more_hits.hits.length
    assert_equal 1, search_after.request_more_hits.hits.length
    assert_equal 3, search_after.total_hits
  end

  private

    def index
      @index ||= Widget.elastic_index
    end
end
