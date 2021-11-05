require "helper"
require "active_support/log_subscriber/test_helper"
require "elastic_record/log_subscriber"

class ElasticRecord::LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super

    ElasticRecord::LogSubscriber.attach_to :elastic_record
  end

  # def set_logger(logger)
  #   ElasticRecord::Model.logger = logger
  # end

  def test_request_notification
    Widget.elastic_connection.json_get "/widgets/_search", { query: { term: { color: "blue" } } }

    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /GET (.*)widgets\/_search/, @logger.logged(:debug)[0]
    assert_match /'{\"query\":{\"term\":{\"color\":\"blue\"}}}'/, @logger.logged(:debug)[0]
  end

  def test_request_notification_escaping
    stub_request(:any, "#{Widget.elastic_connection.servers.first}/widgets?v=%DB").to_return(status: 200, body: Oj.dump('the' => 'response', 'has %DB' => 'odd %DB stuff'))
    Widget.elastic_connection.json_get "/widgets?v=%DB", {'foo' => 'bar', 'escape %DB ' => 'request %DB'}

    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /GET (.*)widgets/, @logger.logged(:debug)[0]
    assert_match %r['#{Oj.dump('foo' => 'bar', 'escape %DB ' => 'request %DB')}'], @logger.logged(:debug)[0]
  end

  def test_initializes_runtime
    Thread.new { assert_equal 0, ElasticRecord::LogSubscriber.runtime }.join
  end
end
