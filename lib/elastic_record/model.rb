module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Connection
        extend Scoping
      end
    end
  end
end