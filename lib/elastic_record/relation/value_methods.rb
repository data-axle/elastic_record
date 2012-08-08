module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:extending, :filter, :facet, :order]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset]
  end
end