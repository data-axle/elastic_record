require 'helper'

class ElasticRecord::NameCacheTest < MiniTest::Test
  class Felon
    include TestModel
  end

  def test_index_name
    begin
      Felon.elastic_index.create_and_deploy("felons_datestamp")
      assert_equal "felons_datestamp", Felon.current_index_name
    ensure
      Felon.elastic_index.delete("felons_datestamp")
    end
  end
end
