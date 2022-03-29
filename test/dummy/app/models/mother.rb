class Mother < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties] = ::Warehouse.elastic_index.mapping[:properties].dup
  self.table_name = 'warehouses'

  son = ::ElasticRecord::Model::Joining::JoinChild.new(klass: Son, parent_id_accessor: ->{ warehouse_id })
  has_es_children(join_field: 'arbitrary', children: son)

  elastic_index.reset
end
