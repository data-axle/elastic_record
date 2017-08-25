module TestPercolatorModel
  extend ActiveSupport::Concern

  included do
    include MockModel
    include ElasticRecord::PercolatorModel
  end
end
