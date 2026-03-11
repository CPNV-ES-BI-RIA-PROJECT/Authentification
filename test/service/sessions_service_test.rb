require_relative '../test_helper'
require_relative '../../src/service/sessions_service'

class SessionsServiceTest < Minitest::Test
  def setup
    @service = SessionsService.new
    @iam_factory = Minitest::Mock.new
    @token_factory = Minitest::Mock.new
    @service.instance_variable_set(:@iam_adapter_factory, @iam_factory)
    @service.instance_variable_set(:@token_adapter_factory, @token_factory)
  end

  def teardown
    @iam_factory.verify
    @token_factory.verify
  end

  def test_login_verifies_credentials_and_creates_token
    previous_iam_provider = ENV['IAM_PROVIDER']
    previous_token_provider = ENV['TOKEN_PROVIDER']
    ENV['IAM_PROVIDER'] = 'custom-iam'
    ENV['TOKEN_PROVIDER'] = 'custom-token'

    iam_adapter = Minitest::Mock.new
    token_adapter = Minitest::Mock.new
    @iam_factory.expect(:get_adapter, iam_adapter, ['custom-iam'])
    iam_adapter.expect(:verify_user_password, true, %w[alice secret])
    @token_factory.expect(:get_adapter, token_adapter, ['custom-token'])
    token_adapter.expect(:create, 'Bearer generated-token', [{ username: 'alice', provider: 'custom-iam' }])

    result = @service.login('alice', 'secret')
    assert_equal 'Bearer generated-token', result
    iam_adapter.verify
    token_adapter.verify
  ensure
    ENV['IAM_PROVIDER'] = previous_iam_provider
    ENV['TOKEN_PROVIDER'] = previous_token_provider
  end

  def test_current_parses_token_and_verifies_it
    token_adapter = Object.new
    called_with = nil
    token_adapter.define_singleton_method(:verify) do |token|
      called_with = token
      { 'username' => 'alice' }
    end
    @token_factory.expect(:get_adapter, token_adapter, ['Bearer'])

    result = @service.current('Bearer abc123')
    assert_equal({ 'username' => 'alice' }, result)
    assert_equal 'abc123', called_with
  end

  def test_logout_parses_token_and_revokes_it
    token_adapter = Object.new
    called_with = nil
    token_adapter.define_singleton_method(:revoke) do |token|
      called_with = token
      nil
    end
    @token_factory.expect(:get_adapter, token_adapter, ['Bearer'])

    result = @service.logout('Bearer abc123')
    assert_nil result
    assert_equal 'abc123', called_with
  end

  def test_current_raises_when_token_is_missing
    assert_raises(AuthorizationTokenIsMissingError) { @service.current(nil) }
    assert_raises(AuthorizationTokenIsMissingError) { @service.current('') }
  end

  def test_logout_raises_when_token_format_is_invalid
    assert_raises(InvalidTokenFormatError) { @service.logout('Bearer too many parts') }
    assert_raises(InvalidTokenFormatError) { @service.logout('only-one-part') }
  end
end
