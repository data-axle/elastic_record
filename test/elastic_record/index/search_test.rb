require "helper"

class ElasticRecord::Index::SearchTest < MiniTest::Test
  def test_build_scroll_enumerator
    index.index_document('bob', name: 'bob')
    index.index_document('joe', name: 'joe')

    scroll_enumerator = index.build_scroll_enumerator(search: {'query' => {query_string: {query: 'name:bob'}}})

    assert_equal 1, scroll_enumerator.total_hits
    assert_equal 1, scroll_enumerator.request_more_ids.size
  end

  def test_expired_scroll_error
    index.index_document('bob', name: 'bob')
    index.index_document('bobs', name: 'bob')

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
    10.times { |i| index.index_document("bob#{i}", color: 'red') }
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

  private

    def index
      @index ||= Widget.elastic_index
    end
end
