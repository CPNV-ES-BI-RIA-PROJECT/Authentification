require 'rack/mock'
require_relative '../test_helper'
require_relative '../../src/http/start'

class DocsControllerTest < Minitest::Test
  def setup
    Sinatra::Application.set :environment, :test
    @request = Rack::MockRequest.new(Sinatra::Application)
  end

  def test_api_docs_route_returns_swagger_ui_page
    response = @request.get('/api/docs')

    assert_equal 200, response.status
    assert_includes response['Content-Type'], 'text/html'
    assert_includes response.body, 'SwaggerUIBundle'
    assert_includes response.body, '/api/docs/openapi.json'
  end

  def test_api_docs_openapi_route_returns_valid_spec # rubocop:disable Metrics/AbcSize
    response = @request.get('/api/docs/openapi.json')
    spec = parse_json(response.body)

    assert_equal 200, response.status
    assert_includes response['Content-Type'], 'application/json'
    assert_equal '3.0.3', spec['openapi']
    assert_equal 'Authentication API', spec.dig('info', 'title')
    assert_equal 'Endpoints for health checks, session creation, inspection and logout for both user and
                  API credentials.',
                 spec.dig('info', 'description')
    assert spec.dig('paths', '/api/v1/health')
    assert spec.dig('paths', '/api/v1/sessions')
    assert_equal '#/components/schemas/HealthResponse',
                 spec.dig('paths', '/api/v1/health', 'get', 'responses', '200', 'content', 'application/json',
                          'schema', '$ref')
    assert_equal '#/components/schemas/LoginRequest',
                 spec.dig('paths', '/api/v1/sessions', 'post', 'requestBody', 'content',
                          'application/x-www-form-urlencoded', 'schema', '$ref')
    assert_equal '#/components/schemas/UserLoginRequest',
                 spec.dig('components', 'schemas', 'LoginRequest', 'oneOf', 0, '$ref')
    assert_equal '#/components/schemas/ApiLoginRequest',
                 spec.dig('components', 'schemas', 'LoginRequest', 'oneOf', 1, '$ref')
    assert_equal %w[access_key_id secret_access_key],
                 spec.dig('components', 'schemas', 'ApiLoginRequest', 'required')
    assert_equal 'Bearer JWT', spec.dig('components', 'securitySchemes', 'bearerAuth', 'bearerFormat')
    assert_equal 'ok', spec.dig('components', 'schemas', 'HealthResponse', 'properties', 'status', 'example')
  end
end
