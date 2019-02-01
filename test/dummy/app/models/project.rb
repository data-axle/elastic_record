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
      'team_members' => {
        type: 'nested',
        properties: {
          'name' => { type: 'text' },
          'estimated_age' => {
            type: 'integer_range'
          }
        }
      },
      'manager' => {
        type: 'object',
        properties: {
          'name' => { type: 'text' },
          'estimated_age' => {
            type: 'integer_range'
          }
        }
      }
    }
  }

  attr_accessor :id,
                :name,
                :estimated_start_date,
                :team_members,
                :manager
  alias_method :as_json, :as_search_document

  class TeamMember
    include ActiveModel::Model
    include ElasticRecord::Model

    attr_accessor :name, :estimated_age
  end
end
