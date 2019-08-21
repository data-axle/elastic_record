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
  autoload :FromSearchHit
  autoload :Index
  autoload :Lucene
  autoload :ElasticConnection
  autoload :Model
  autoload :PercolatorModel
  autoload :Relation
  autoload :Searching
  autoload :SearchHits

  module AggregationResponse
    extend ActiveSupport::Autoload

    autoload :Aggregation
    autoload :Bucket
    autoload :Builder
    autoload :HasAggregations
    autoload :MultiBucketAggregation
    autoload :MultiValueAggregation
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
