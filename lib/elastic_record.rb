require 'arelastic'
require 'active_support/concern'
require 'active_model'

module ElasticRecord
  extend ActiveSupport::Autoload
  autoload :Config
  autoload :Connection
  autoload :Doctype
  autoload :Index
  autoload :Lucene
  autoload :Model
  autoload :PercolatorModel
  autoload :Relation
  autoload :SearchHits

  module Model
    extend ActiveSupport::Autoload

    autoload :AsDocument
    autoload :Callbacks
    autoload :ElasticConnection
    autoload :FromSearchHit
    autoload :Joining
    autoload :Searching
  end

  module AggregationResponse
    extend ActiveSupport::Autoload

    autoload :Aggregation
    autoload :Bucket
    autoload :Builder
    autoload :HasAggregations
    autoload :MultiBucketAggregation
    autoload :MultiValueAggregation
    autoload :ParentAggregation
    autoload :SingleBucketAggregation
    autoload :SingleValueAggregation
  end

  class << self
    def configure
      yield(ElasticRecord::Config)
    end
  end
end

require 'elastic_record/errors'
require 'elastic_record/railtie' if defined?(Rails)
