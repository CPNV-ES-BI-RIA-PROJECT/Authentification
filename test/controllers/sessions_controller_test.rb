require 'rack/mock'
require_relative '../test_helper'
require_relative '../../src/http/start'

class SessionsControllerTest < Minitest::Test
  def setup
    Sinatra::Application.set :environment, :test
    @request = Rack::MockRequest.new(Sinatra::Application)
  end

  def test_get_sessions_returns_current_user_payload
    service = Minitest::Mock.new
    service.expect(:current, { username: 'alice', provider: 'fake' }, ['Bearer token-value'])

    response = SessionsService.stub(:new, service) do
      @request.get('/api/v1/sessions', 'HTTP_AUTHORIZATION' => 'Bearer token-value')
    end

    assert_equal 200, response.status
    assert_equal({ 'username' => 'alice', 'provider' => 'fake' }, parse_json(response.body))
    service.verify
  end

  def test_get_sessions_returns_unauthorized_on_token_error
    service = Object.new
    def service.current(_token)
      raise InvalidTokenError, 'Invalid token'
    end

    response = SessionsService.stub(:new, service) do
      @request.get('/api/v1/sessions', 'HTTP_AUTHORIZATION' => 'Bearer bad-token')
    end

    assert_equal 401, response.status
    assert_equal({ 'error' => 'Invalid token' }, parse_json(response.body))
  end

  def test_post_sessions_returns_token
    service = Minitest::Mock.new
    service.expect(:login, 'Bearer generated-token', %w[alice secret fake bearer])

    response = SessionsService.stub(:new, service) do
      @request.post(
        '/api/v1/sessions',
        params: {
          username: 'alice',
          password: 'secret',
          provider: 'fake',
          token_provider: 'bearer'
        }
      )
    end

    assert_equal 200, response.status
    assert_equal({ 'token' => 'Bearer generated-token' }, parse_json(response.body))
    service.verify
  end

  def test_post_sessions_returns_bad_request_when_parameters_are_missing
    response = @request.post('/api/v1/sessions', params: { username: 'alice' })

    assert_equal 400, response.status
    assert_equal({ 'error' => 'Missing parameters' }, parse_json(response.body))
  end

  def test_post_sessions_returns_unauthorized_on_token_error
    service = Object.new
    def service.login(*)
      raise InvalidTokenError, 'Login failed'
    end

    response = SessionsService.stub(:new, service) do
      @request.post(
        '/api/v1/sessions',
        params: {
          username: 'alice',
          password: 'secret',
          provider: 'fake',
          token_provider: 'bearer'
        }
      )
    end

    assert_equal 401, response.status
    assert_equal({ 'error' => 'Login failed' }, parse_json(response.body))
  end

  def test_post_sessions_returns_bad_request_on_unknown_adapter_type
    service = Object.new
    def service.login(*)
      raise UnknownAdapterTypeError, 'Unknown adapter type: ldap'
    end

    response = SessionsService.stub(:new, service) do
      @request.post(
        '/api/v1/sessions',
        params: {
          username: 'alice',
          password: 'secret',
          provider: 'ldap',
          token_provider: 'bearer'
        }
      )
    end

    assert_equal 400, response.status
    assert_equal({ 'error' => 'Unknown adapter type: ldap' }, parse_json(response.body))
  end

  def test_delete_sessions_calls_logout
    service = Minitest::Mock.new
    service.expect(:logout, nil, ['Bearer token-value'])

    response = SessionsService.stub(:new, service) do
      @request.delete('/api/v1/sessions', 'HTTP_AUTHORIZATION' => 'Bearer token-value')
    end

    assert_equal 200, response.status
    service.verify
  end

  def test_delete_sessions_returns_unauthorized_on_token_error
    service = Object.new
    def service.logout(_token)
      raise InvalidTokenError, 'Invalid token'
    end

    response = SessionsService.stub(:new, service) do
      @request.delete('/api/v1/sessions', 'HTTP_AUTHORIZATION' => 'Bearer bad-token')
    end

    assert_equal 401, response.status
    assert_equal({ 'error' => 'Invalid token' }, parse_json(response.body))
  end
end
