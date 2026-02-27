require_relative '../config'

get "#{PREFIX}sessions" do
  content_type :json

  { message: 'hello world' }.to_json
end
