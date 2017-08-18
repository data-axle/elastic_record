require 'helper'

class ElasticRecord::Index::ConfiguratorTest < MiniTest::Test
  # TODO:  will probably end up going away entirely

  private
    def configurator
      @configurator ||= begin
        index = ElasticRecord::Index.new(Widget)
        ElasticRecord::Index::Configurator.new(index)
      end
    end
end
