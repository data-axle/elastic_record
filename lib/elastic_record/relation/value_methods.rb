module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:extending, :filter, :order, :select, :aggregation]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset, :search_type, :reverse_order]
  end
end
