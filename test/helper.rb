require 'bundler/setup'
Bundler.require

require 'minitest/autorun'

require 'support/connect'
require 'support/models/test_model'
require 'support/models/warehouse'
require 'support/models/widget'
require 'support/models/option'

ElasticRecord::Config.model_names = %w(Warehouse Widget Option)

FakeWeb.allow_net_connect = %r[^https?://127.0.0.1]

module MiniTest
  class Spec
    def setup
      super

      Widget._test_cache.clear
      Option._test_cache.clear

      FakeWeb.clean_registry

      Widget.elastic_index.create_and_deploy if Widget.elastic_index.all_names.empty?

      ElasticRecord::Config.models.each do |model|
        model.elastic_index.enable_deferring!
      end
    end

    def teardown
      ElasticRecord::Config.models.each do |model|
        model.elastic_index.reset_deferring!
      end
    end

    def assert_queries(num = 1, options = {})
      ignore_none = options.fetch(:ignore_none) { num == :any }
      ElasticSearchCounter.clear_log
      x = yield
      the_log = ignore_none ? ElasticSearchCounter.log_all : ElasticSearchCounter.log
      if num == :any
        assert_operator the_log.size, :>=, 1, "1 or more queries expected, but none were executed."
      else
        queries = the_log.map { |event| "  #{event[:request].method} #{event[:request].path} #{event[:request].body}\n" }.join("\n")

        mesg = "#{the_log.size} instead of #{num} queries were executed.#{the_log.size == 0 ? '' : "\nQueries:\n#{queries}"}"
        assert_equal num, the_log.size, mesg
      end

      x
    end

    def assert_no_queries(&block)
      assert_queries(0, :ignore_none => true, &block)
    end
  end

  class ElasticSearchCounter
    class << self
      attr_accessor :ignored_elastic, :log, :log_all
      def clear_log; self.log = []; self.log_all = []; end
    end

    self.clear_log

    self.ignored_elastic = []

    elastic_search_ignored = []

    [elastic_search_ignored].each do |db_ignored_elastic|
      ignored_elastic.concat db_ignored_elastic
    end

    attr_reader :ignore

    def initialize(ignore = Regexp.union(self.class.ignored_elastic))
      @ignore = ignore
    end

    def call(name, start, finish, message_id, values)
      self.class.log_all << values
      self.class.log << values unless ignore =~ values[:request].path
    end
  end

  ActiveSupport::Notifications.subscribe('request.elastic_record', ElasticSearchCounter.new)
end
