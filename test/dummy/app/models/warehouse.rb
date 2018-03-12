class Warehouse < ActiveRecord::Base
  include ElasticRecord::Model

  self.doctype.mapping[:properties].update(
    'name' => { type: 'text', index: false }
  )
end
