class Warehouse < ActiveRecord::Base
  include ElasticRecord::Model

  self.doctype.mapping[:properties].update(
    'name' => { type: 'keyword' }
  )
end
