require_relative '../config'
require_relative '../../service/sessions_service'
require_relative '../../exceptions/token/token_error'

before do
  @sessions_service = SessionsService.new
end

get "#{PREFIX}sessions" do
  content_type :json

  token = request.env['HTTP_AUTHORIZATION']

  @sessions_service.current(token).to_json
rescue TokenError => e
  status 401
  { error: e.message }.to_json
end

post "#{PREFIX}sessions" do
  content_type :json

  unless params[:username] && params[:password] && params[:provider] && params[:token_provider]
    return status 400, { error: 'Missing parameters' }.to_json
  end

  { token: @sessions_service.login(params[:username], params[:password], params[:provider], params[:token_provider]) }.to_json
rescue TokenError => e
  status 401
  { error: e.message }.to_json
end

delete "#{PREFIX}sessions" do
  content_type :json

  token = request.env['HTTP_AUTHORIZATION']
  @sessions_service.logout(token)
rescue TokenError => e
  status 401
  { error: e.message }.to_json
end
