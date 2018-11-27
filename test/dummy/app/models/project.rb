class Project
  class << self
    def base_class
      self
    end
  end

  include ActiveModel::Model
  include ElasticRecord::Model
  elastic_index.load_from_source!

  attr_accessor :id, :name
  alias_method :as_json, :as_search_document

  def as_search_document
    { name: name }
  end
end
