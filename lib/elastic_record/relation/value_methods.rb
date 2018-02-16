module ElasticRecord
  class Relation
    MULTI_VALUE_METHODS  = [:extending, :filter, :order, :aggregation]
    SINGLE_VALUE_METHODS = [:query, :limit, :offset, :search_options, :search_type, :reverse_order]
  end
end
