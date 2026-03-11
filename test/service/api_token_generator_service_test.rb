require_relative '../test_helper'
require_relative '../../src/service/api_token_generator_service'

class APITokenGeneratorServiceTest < Minitest::Test
  def setup
    @service = APITokenGeneratorService.new
    @token_factory = Minitest::Mock.new
    @service.instance_variable_set(:@token_adapter_factory, @token_factory)
  end

  def teardown
    @token_factory.verify
  end

  def test_generate_api_token_uses_configured_provider
    previous_token_provider = ENV['TOKEN_PROVIDER']
    ENV['TOKEN_PROVIDER'] = 'custom-token'

    token_adapter = Minitest::Mock.new
    @token_factory.expect(:get_adapter, token_adapter, ['custom-token'])
    token_adapter.expect(:create, 'Bearer api-token', [{ type: 'api' }])

    assert_equal 'Bearer api-token', @service.generate_api_token
    token_adapter.verify
  ensure
    restore_env_token_provider(previous_token_provider)
  end

  def test_generate_api_token_falls_back_to_default_provider
    previous_token_provider = ENV.delete('TOKEN_PROVIDER')

    token_adapter = Minitest::Mock.new
    @token_factory.expect(:get_adapter, token_adapter, ['jwt'])
    token_adapter.expect(:create, 'Bearer default-token', [{ type: 'api' }])

    assert_equal 'Bearer default-token', @service.generate_api_token
    token_adapter.verify
  ensure
    restore_env_token_provider(previous_token_provider)
  end

  private

  def restore_env_token_provider(value)
    if value.nil?
      ENV.delete('TOKEN_PROVIDER')
    else
      ENV['TOKEN_PROVIDER'] = value
    end
  end
end
