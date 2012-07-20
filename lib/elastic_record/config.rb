module ElasticRecord
  class Config
    class << self
      def servers=(value)
        @servers = value
      end

      def servers
        @servers
      end
    end
  end
end
