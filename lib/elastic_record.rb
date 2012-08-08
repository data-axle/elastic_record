require 'arelastic'

module ElasticRecord
  autoload :Config, 'elastic_record/config'
  autoload :Connection, 'elastic_record/connection'
  autoload :Index, 'elastic_record/index'
  autoload :Model, 'elastic_record/model'
  autoload :Relation, 'elastic_record/relation'
  autoload :Searching, 'elastic_record/searching'
end
