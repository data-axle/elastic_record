class Project < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties].update(
    'name' => { type: 'keyword' }
  )
end
