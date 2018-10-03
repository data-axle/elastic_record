class WidgetQuery
  include TestPercolatorModel

  define_attributes [:name, :color]

  self.percolates_model = Widget
  self.elastic_index.type = 'widget'

  def as_search_document
    filters = {}
    filters[:name] = name if name
    filters[:color] = color if color
    percolates_model.elastic_search.filter(filters).as_elastic
  end
end
