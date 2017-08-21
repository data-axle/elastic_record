require 'helper'

class ElasticRecord::Relation::AdminTest < MiniTest::Test
  def test_create_warmer
  end

  private

    def index
      Widget.elastic_index
    end
end
