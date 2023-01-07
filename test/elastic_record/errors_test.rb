require 'helper'

class ElasticRecord::ErrorsTest < MiniTest::Test
  def test_connection_error_with_a_payload
    response_body   = '{"foo": "bar"}'
    request_payload = '{"fiz": "buz"}'
    ElasticRecord::ConnectionError.new(200, response_body, request_payload)
  end

  def test_connection_error_without_a_payload
    response_body = '{"foo": "bar"}'
    ElasticRecord::ConnectionError.new(200, response_body)
  end
end
