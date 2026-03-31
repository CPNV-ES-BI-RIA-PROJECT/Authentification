require_relative '../config'
require_relative '../../service/sessions_service'
require_relative '../../exceptions/missing_parameters_error'

before do
  @sessions_service = SessionsService.new
end

get "#{PREFIX}sessions" do
  content_type :json

  token = request.env['HTTP_AUTHORIZATION']

  @sessions_service.current(token).to_json
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
    raise MissingParametersError
  end
end

delete "#{PREFIX}sessions" do
  content_type :json

  token = request.env['HTTP_AUTHORIZATION']
  @sessions_service.logout(token)
end
