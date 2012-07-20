module ElasticRecord
  module FinderMethods
    def find(id)
      filter(arelastic.filter.ids(id)).to_a.first
    end

    def first
      limit(1).to_a.first
    end
  end
end