class WidgetQuery
  include TestPercolatorModel

  define_attributes [:name, :color]

  self.percolates_model = Widget

  doctype.mapping = {
    properties: {
      name: { type: 'keyword' },
      color: { type: 'keyword' },
      query: { type: 'percolator' }
    }
  }

  def as_search_document
    filters = {}
    filters[:name] = name if name
    filters[:color] = color if color
    percolates_model.elastic_search.filter(filters).as_elastic
  end
end
