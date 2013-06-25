module CassandraObject
  class Base
    def self.load_elastic_record_hits(ids)
      find(ids)
    end
  end
end
