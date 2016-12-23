module ElasticRecord
  module JSON
    class << self
      def parser
        @@parser ||= :active_support
      end

      def parser=(value)
        @@parser = value
      end

      def decode(json)
        if ElasticRecord::JSON.parser == :oj
          Oj.compat_load(json)
        else
          ActiveSupport::JSON.decode(json)
        end
      end

      def encode(data)
        if ElasticRecord::JSON.parser == :oj
          Oj.dump(data, mode: :compat, use_as_json: true)
        else
          ActiveSupport::JSON.encode(data)
        end
      end
    end
  end
end
