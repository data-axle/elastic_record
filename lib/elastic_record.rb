require 'arelastic'
require 'rubberband'
require 'active_support/core_ext/object/blank' # required because ActiveModel depends on this but does not require it
require 'active_model'

module ElasticRecord
  autoload :Callbacks, 'elastic_record/callbacks'
  autoload :Config, 'elastic_record/config'
  autoload :Connection, 'elastic_record/connection'
  autoload :Index, 'elastic_record/index'
  autoload :Model, 'elastic_record/model'
  autoload :Relation, 'elastic_record/relation'
  autoload :Searching, 'elastic_record/searching'
end

require 'elastic_record/railtie' if defined?(Rails)