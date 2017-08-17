class WidgetQuery
  include TestPercolatorModel

  define_attributes [:name, :color]

  self.target_model = Widget

  def as_arelastic
    target_model.filter(name: name, color: color).to_arelastic
  end
end
