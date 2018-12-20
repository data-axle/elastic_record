class SourceModel
  include TestModel
  elastic_index.load_from_source!
  elastic_index.mapping[:properties].update(
    'path' => { type: 'keyword' }
  )

  attr_accessor :path
end
