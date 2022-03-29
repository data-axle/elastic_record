class Son < ActiveRecord::Base
  include ElasticRecord::Model

  self.elastic_index.mapping[:properties] = ::Widget.elastic_index.mapping[:properties].dup

  self.table_name = 'widgets'

  belongs_to :mother, foreign_key: :warehouse_id
end
