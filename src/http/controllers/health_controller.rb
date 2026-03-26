require 'json'
require_relative '../config'

get "#{PREFIX}health" do
  content_type :json

  {
    status: 'ok',
    version: API_VERSION
  }.to_json
end
