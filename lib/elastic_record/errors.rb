module ElasticRecord
  class Error < StandardError
  end

  class ConnectionError < Error
  end

  class ScrollKeepAliveError < Error
  end
end