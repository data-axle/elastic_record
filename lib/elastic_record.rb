module ElasticRecord
  autoload :Config, 'elastic_record/config'
  autoload :Connection, 'elastic_record/connection'

  autoload :Relation, 'elastic_record/relation'
  autoload :Delegation, 'elastic_record/relation/delegation'
  autoload :FinderMethods, 'elastic_record/relation/finder_methods'
  autoload :Merging, 'elastic_record/relation/merging'
  autoload :SearchMethods, 'elastic_record/relation/search_methods'

  autoload :Searching, 'elastic_record/searching'

  autoload :Model, 'elastic_record/model'
end
