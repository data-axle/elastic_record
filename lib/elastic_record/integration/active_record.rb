module ActiveRecord
  class Base
    def self.load_elastic_record_hits(ids)
      order("FIELD(#{connection.quote_column_name(primary_key)}, #{ids.join(',')})").find(ids)
    end
  end
end
