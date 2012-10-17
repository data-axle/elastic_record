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

  attr_writer :id
  def initialize(attributes = {})
    attributes.each do |key, val|
      send("#{key}=", val)
    end
  end

  def id
    @id ||= rand(10000).to_s
  end

  def save
    @persisted = true
    run_callbacks :save
  end

  def destroy
    @destroyed = true
    run_callbacks :destroy
  end

  def changed?
    true
  end

  def new_record?
    !@persisted
  end

  def persisted?
    @persisted
  end

  def destroyed?
    @destroyed
  end
end
