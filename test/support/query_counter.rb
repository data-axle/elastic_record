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

module MiniTest
  class Spec
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
end