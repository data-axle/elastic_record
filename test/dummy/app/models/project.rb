class TeamMember
  include ActiveModel::Model
  include ElasticRecord::Model

  attr_accessor :name, :estimated_age

  elastic_index.mapping = {
    properties: {
      'name' => { type: 'text' },
      'estimated_age' => {
        type: 'integer_range'
      }
    }
  }
end

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
        properties: TeamMember.elastic_index.mapping[:properties]
      },
      'manager' => {
        type: 'object',
        properties: TeamMember.elastic_index.mapping[:properties]
      }
    }
  }

  attr_accessor :id,
                :name,
                :estimated_start_date,
                :team_members,
                :manager
  alias_method :as_json, :as_search_document
end
