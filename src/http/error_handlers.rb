require 'json'
require_relative '../exceptions/application_error'

error ApplicationError do
  content_type :json

  exception = env['sinatra.error']
  status exception.status
  { error: exception.message }.to_json
end
