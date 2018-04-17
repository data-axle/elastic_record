require 'arelastic'
require 'active_support/concern'
require 'active_model'

module ElasticRecord
  extend ActiveSupport::Autoload
  autoload :AsDocument
  autoload :Callbacks
  autoload :Config
  autoload :Connection
  autoload :Doctype
  autoload :Index
  autoload :Lucene
  autoload :Model
  autoload :PercolatorModel
  autoload :Relation
  autoload :Searching

  class << self
    def configure
      yield(ElasticRecord::Config)
    end
  end
end

require 'elastic_record/errors'
require 'elastic_record/railtie' if defined?(Rails)
