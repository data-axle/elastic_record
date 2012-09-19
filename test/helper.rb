require 'bundler/setup'
Bundler.require

require 'minitest/autorun'

require 'support/widget'
require 'support/connect'

# FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https?://127.0.0.1]

module MiniTest
  class Spec
    def setup
      super
      FakeWeb.clean_registry
    end
  end
end
