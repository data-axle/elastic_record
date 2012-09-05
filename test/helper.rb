require 'bundler/setup'
Bundler.require

require 'minitest/autorun'

require 'active_support/core_ext/object/blank'
require 'active_model'

require 'support/widget'
require 'support/connect'

module MiniTest
  class Spec
  end
end
