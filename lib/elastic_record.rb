module ElasticRecord
  autoload :Connection, 'elastic_record/connection'
  autoload :Scoping, 'elastic_record/scoping'

  autoload :Relation, 'elastic_record/relation'
  autoload :Delegation, 'elastic_record/relation/delegation'
  autoload :FinderMethods, 'elastic_record/relation/finder_methods'
  autoload :SearchMethods, 'elastic_record/relation/search_methods'

  autoload :Model, 'elastic_record/model'
end
