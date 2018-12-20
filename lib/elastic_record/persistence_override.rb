module ElasticRecord
  module PersistenceOverride
    def save(*)
      true
    end
  end
end
