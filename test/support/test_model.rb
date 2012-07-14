class TestModel < Struct.new(:id)
  include ElasticRecord::Model

  class << self
    def find(ids)
      ids.map { |id| new(id) }
    end
  end
end