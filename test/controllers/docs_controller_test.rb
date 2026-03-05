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

  def test_api_docs_openapi_route_returns_valid_spec
    response = @request.get('/api/docs/openapi.json')
    spec = parse_json(response.body)

    assert_equal 200, response.status
    assert_includes response['Content-Type'], 'application/json'
    assert_equal '3.0.3', spec['openapi']
    assert_equal 'Authentication API', spec.dig('info', 'title')
    assert spec.dig('paths', '/api/v1/sessions')
  end
end
