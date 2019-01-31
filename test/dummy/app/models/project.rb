class Project
  class << self
    def base_class
      self
    end
  end

  include ActiveModel::Model
  include ElasticRecord::Model
  elastic_index.load_from_source!
  elastic_index.mapping = {
    properties: {
      'name' => {
        type: 'text'
      },
      'estimated_start_date' => {
        type: 'date_range'
      },
      'estimated_hours' => {
        type: 'integer_range'
      }
    }
  }

  attr_accessor :id, :name, :estimated_start_date, :estimated_hours
  alias_method :as_json, :as_search_document
end
