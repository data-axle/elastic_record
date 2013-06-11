module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:extending, :facet, :filter, :order, :select, :eager_load]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset, :reverse_order]
  end
end
