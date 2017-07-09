module ElasticRecord
  class Index
    module Analyze
      def analyze(params)
        json = connection.json_get "/#{alias_name}/_analyze", params
        json['tokens'].map { |token_hash| token_hash['token'] }
      end
    end
  end
end
