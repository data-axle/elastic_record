class Warehouse < ActiveRecord::Base
  include ElasticRecord::Model

  elastic_index.mapping_type = 'warehouse'
  elastic_index.mapping[:properties].update(
    'name' => { type: 'keyword' }
  )
end
