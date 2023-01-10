require 'helper'

class ElasticRecord::ConnectionTest < MiniTest::Test
  def test_servers
    assert_equal ['foo'], ElasticRecord::Connection.new('foo').servers
    assert_equal ['foo', 'bar'], ElasticRecord::Connection.new(['foo', 'bar']).servers
  end

  def test_options
    expected = {lol: 'rofl'}
    assert_equal expected, ElasticRecord::Connection.new('foo', 'lol' => 'rofl').options
  end

  def test_head
    stub_es_request(:head, "/success").to_return(status: 200)

    assert_equal "200", connection.head("/success")

    stub_es_request(:head, "/failure").to_return(status: 404)
    assert_equal "404", connection.head("/failure")
  end

  def test_json_requests
    expected = {'foo' => 'bar'}
    stub_es_request(:any, "/test").to_return(status: 200, body: JSON.generate(expected))

    assert_equal expected, connection.json_delete("/test")
    assert_equal expected, connection.json_get("/test")
    assert_equal expected, connection.json_post("/test")
    assert_equal expected, connection.json_put("/test")
  end

  def test_json_request_with_valid_error_status
    request  = { 'some' => 'payload' }
    response = { 'error' => 'Doing it wrong' }

    stub_es_request(:get, "/error").to_return(status: 404, body: response.to_json)

    error = assert_raises ElasticRecord::ConnectionError do
      connection.json_get("/error", request.to_json)
    end

    expected = {
      elasticsearch_response: response,
      request_payload:        request,
    }.to_json
    assert_equal expected, error.message
  end

  def test_retry_server_exceptions
    responses = [
      {exception: Errno::ECONNREFUSED},
      {status: ["200", "OK"], body: JSON.generate('hello' => 'world')}
    ]

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 0).tap do |connection|
      stub_es_request(:get, "/error").to_return(*responses)
      assert_raises(Errno::ECONNREFUSED) { connection.json_get("/error") }
    end

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 1).tap do |connection|
      stub_es_request(:get, "/error").to_return(*responses)
      json = connection.json_get("/error")
      assert_equal({'hello' => 'world'}, json)
    end
  end

  def test_retry_server_500_errors
    response_1 = { 'error' => 'temporarily_unavailable' }
    response_2 = {'hello' => 'world'}
    responses = [
      { status: %w(500 OK), body: response_1.to_json },
      { status: %w(200 OK), body: response_2.to_json }
    ]

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 0).tap do |connection|
      stub_es_request(:get, "/error").to_return(*responses)

      error = assert_raises ElasticRecord::ConnectionError do
        connection.json_get("/error")
      end

      assert_equal '500', error.status_code
      expected = {
        elasticsearch_response: response_1,
        request_payload:        nil
      }.to_json
      assert_equal expected, error.message
    end

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 1).tap do |connection|
      stub_es_request(:get, "/error").to_return(*responses)
      assert_equal response_2, connection.json_get("/error")
    end
  end

  private

    def connection
      ElasticRecord::Connection.new(ElasticRecord::Config.servers)
    end

    def stub_es_request(method, path)
      stub_request(method, "#{connection.servers.first}#{path}")
    end
end
