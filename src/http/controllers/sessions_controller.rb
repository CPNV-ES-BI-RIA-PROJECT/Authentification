require_relative '../config'
require_relative '../../service/sessions_service'
require_relative '../../exceptions/token/token_error'
require_relative '../../exceptions/invalid_credentials_error'
require_relative '../../exceptions/unknown_adapter_type_error'

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

  if params[:username] && params[:password]
    return {
      token: @sessions_service.login(
        params[:username], params[:password], 'auth'
      )
    }.to_json
  elsif params[:access_key_id] && params[:secret_access_key]
    return {
      token: @sessions_service.login(
        params[:access_key_id], params[:secret_access_key], 'api'
      )
    }.to_json
  else
    status 400
    return { error: 'Missing required parameters' }.to_json
  end
rescue UnknownAdapterTypeError => e
  status 400
  { error: e.message }.to_json
rescue InvalidCredentialsError
  status 401
  { error: 'Invalid username or password' }.to_json
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
