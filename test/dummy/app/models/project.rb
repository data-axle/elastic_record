class Project < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties].update(
    'name' => { type: 'string', index: 'not_analyzed' }
  )
end
