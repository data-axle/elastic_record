class Warehouse
  class << self
    def base_class
      self
    end
  end

  include ActiveModel::Model
  include ElasticRecord::Model

  attr_accessor :id, :name
  alias_method :as_json, :as_search_document

  elastic_index.load_from_source = true
end
