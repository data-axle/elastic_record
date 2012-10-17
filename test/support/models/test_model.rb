module TestModel
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    define_model_callbacks :save, :destroy
    include ActiveModel::Validations

    include ElasticRecord::Model
    include ElasticRecord::Callbacks
  end

  module ClassMethods
    def find(ids)
      ids.map { |id| new(id: id, color: 'red') }
    end

    def base_class
      self
    end

    def create(attributes = {})
      record = new(attributes)
      record.save
      record
    end
  end

  def initialize(attributes = {})
    attributes.each do |key, val|
      send("#{key}=", val)
    end
  end

  def save
    run_callbacks :save
  end

  def destroy
    run_callbacks :destroy
  end
end
