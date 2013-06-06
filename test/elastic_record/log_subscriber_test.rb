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
    FakeWeb.register_uri(:any, %r[/test], status: ["200", "OK"], body: ActiveSupport::JSON.encode('the' => 'response'))
    Widget.elastic_connection.json_get "/test", {'foo' => 'bar'}

    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /GET (.*)test/, @logger.logged(:debug)[0]
    assert_match %r['#{ActiveSupport::JSON.encode('foo' => 'bar')}'], @logger.logged(:debug)[0]
  end

  def test_request_notification_escaping
    FakeWeb.register_uri(:any, %r[/test?v=%DB], status: ["200", "OK"], body: ActiveSupport::JSON.encode('the' => 'response', 'has %DB' => 'odd %DB stuff'))
    Widget.elastic_connection.json_get "/test?v=%DB", {'foo' => 'bar', 'escape %DB ' => 'request %DB'}

    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /GET (.*)test/, @logger.logged(:debug)[0]
    assert_match %r['#{ActiveSupport::JSON.encode('foo' => 'bar', 'escape %DB ' => 'request %DB')}'], @logger.logged(:debug)[0]
  end

  def test_initializes_runtime
    Thread.new { assert_equal 0, ElasticRecord::LogSubscriber.runtime }.join
  end
end
