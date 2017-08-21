class WidgetQuery
  include TestPercolatorModel

  define_attributes [:name, :color]

  self.target_model = Widget

  def as_search
    filters = {}
    filters[:name] = name if name
    filters[:color] = color if color
    target_model.elastic_search.filter(filters).as_elastic
  end
end
