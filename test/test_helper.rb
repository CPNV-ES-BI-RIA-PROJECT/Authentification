require 'simplecov'
SimpleCov.external_at_exit = true
SimpleCov.start do
  add_filter '/test/'
  add_filter '/docs/'
  add_filter '/storages/'
end

require 'json'
require 'minitest/autorun'

module TestHelper
  def parse_json(body)
    JSON.parse(body)
  end
end

module Minitest
  class Test
    include TestHelper
  end
end
