require 'arelastic'
require 'active_support/concern'
require 'active_model'

module ElasticRecord
  autoload :AsDocument, 'elastic_record/as_document'
  autoload :Callbacks, 'elastic_record/callbacks'
  autoload :Config, 'elastic_record/config'
  autoload :Connection, 'elastic_record/connection'
  autoload :Doctype, 'elastic_record/doctype'
  autoload :Index, 'elastic_record/index'
  autoload :Lucene, 'elastic_record/lucene'
  autoload :Model, 'elastic_record/model'
  autoload :NameCache, 'elastic_record/name_cache'
  autoload :PercolatorModel, 'elastic_record/percolator_model'
  autoload :Relation, 'elastic_record/relation'
  autoload :Searching, 'elastic_record/searching'

  class << self
    def configure
      yield(ElasticRecord::Config)
    end
  end
end

require 'elastic_record/errors'
require 'elastic_record/railtie' if defined?(Rails)
