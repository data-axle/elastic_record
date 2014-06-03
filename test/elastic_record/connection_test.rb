require 'helper'

class ElasticRecord::ConnectionTest < MiniTest::Unit::TestCase
  def test_servers
    assert_equal ['foo'], ElasticRecord::Connection.new('foo').servers
    assert_equal ['foo', 'bar'], ElasticRecord::Connection.new(['foo', 'bar']).servers
  end

  def test_options
    expected = {lol: 'rofl'}
    assert_equal expected, ElasticRecord::Connection.new('foo', 'lol' => 'rofl').options
  end

  def test_head
    FakeWeb.register_uri(:head, %r[/success], status: ["200", "OK"])
    assert_equal "200", connection.head("/success")

    FakeWeb.register_uri(:head, %r[/failure], status: ["404", "Not Found"])
    assert_equal "404", connection.head("/failure")
  end

  def test_json_requests
    expected = {'foo' => 'bar'}
    FakeWeb.register_uri(:any, %r[/test], status: ["200", "OK"], body: ActiveSupport::JSON.encode(expected))

    assert_equal expected, connection.json_delete("/test")
    assert_equal expected, connection.json_get("/test")
    assert_equal expected, connection.json_post("/test")
    assert_equal expected, connection.json_put("/test")
  end

  def test_json_request_with_error_status
    response_json = {'error' => 'Doing it wrong'}
    FakeWeb.register_uri(:get, %r[/error], status: ["404", "Not Found"], body: ActiveSupport::JSON.encode(response_json))

    error = assert_raises ElasticRecord::ConnectionError do
      connection.json_get("/error")
    end

    assert_equal 'Doing it wrong', error.message
  end

  def test_execute_retries
    responses = [
      {exception: Errno::ECONNREFUSED},
      {status: ["200", "OK"], body: ActiveSupport::JSON.encode('hello' => 'world')}
    ]

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 0).tap do |connection|
      FakeWeb.register_uri :get, %r[/error], responses
      assert_raises(Errno::ECONNREFUSED) { connection.json_get("/error") }
    end

    ElasticRecord::Connection.new(ElasticRecord::Config.servers, retries: 1).tap do |connection|
      FakeWeb.register_uri :get, %r[/error], responses
      json = connection.json_get("/error")
      assert_equal({'hello' => 'world'}, json)
    end
  end

  private
    def connection
      ElasticRecord::Connection.new(ElasticRecord::Config.servers)
    end
end
