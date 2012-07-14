module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        include Connection
        include Scoping
      end
    end
  end
end