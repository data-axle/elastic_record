class Warehouse
  include TestModel

  attr_accessor :name
  searches_many :widgets
end