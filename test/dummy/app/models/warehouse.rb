class Warehouse < ActiveRecord::Base
  include ElasticRecord::Model

  self.doctype.mapping[:properties].update(
    'name' => { type: 'string', index: 'not_analyzed' }
  )
end
