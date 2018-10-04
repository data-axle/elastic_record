module ElasticRecord
  class Index
    module Analyze
      attr_accessor :analysis

      def analysis
        @analysis ||= {}
      end

      def analysis=(custom_analysis)
        analysis.deep_merge!(custom_analysis)
      end

      def analyze(params)
        json = connection.json_get "/#{alias_name}/_analyze", params
        json['tokens'].map { |token_hash| token_hash['token'] }
      end
    end
  end
end
