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
    Widget.elastic_connection.head "/widgets"

    wait

    assert_equal 1, @logger.logged(:info).size
    assert_match "HEAD /widgets", @logger.logged(:info)[0]
    # assert_match(/\-\-\> 200 200 33/, @logger.logged(:info)[1])
  end
end
