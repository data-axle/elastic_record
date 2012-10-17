class Warehouse
  include TestModel

  define_attributes [:name]
  searches_many :widgets
end