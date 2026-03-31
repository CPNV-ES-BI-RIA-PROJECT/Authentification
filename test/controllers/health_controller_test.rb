require 'rack/mock'
require_relative '../test_helper'
require_relative '../../src/http/start'

class HealthControllerTest < Minitest::Test
  def setup
    Sinatra::Application.set :environment, :test
    @request = Rack::MockRequest.new(Sinatra::Application)
  end

  def test_get_health_returns_ok_payload
    response = @request.get('/api/v1/health')

    assert_equal 200, response.status
    assert_includes response['Content-Type'], 'application/json'
    assert_equal(
      {
        'status' => 'ok',
        'version' => 'v1'
      },
      parse_json(response.body)
    )
  end
end
