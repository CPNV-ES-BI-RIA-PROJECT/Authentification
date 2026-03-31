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

  def test_login_raises_when_credentials_are_invalid
    previous_iam_provider = ENV['IAM_PROVIDER']
    ENV['IAM_PROVIDER'] = 'custom-iam'

    iam_adapter = Minitest::Mock.new
    @iam_factory.expect(:get_adapter, iam_adapter, ['custom-iam'])
    iam_adapter.expect(:verify_user_password, false, %w[alice wrong-secret])

    error = assert_raises(InvalidCredentialsError) do
      @service.login('alice', 'wrong-secret')
    end

    assert_equal 'Invalid credentials provided', error.message
    iam_adapter.verify
  ensure
    ENV['IAM_PROVIDER'] = previous_iam_provider
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
    assert_raises(InvalidTokenFormatError) { @service.logout('Bearer') }
    assert_raises(InvalidTokenFormatError) { @service.logout('only-one-part') }
  end

  def test_current_handles_aws_signed_authorization_header
    token_adapter = Object.new
    called_with = nil
    token_adapter.define_singleton_method(:verify) do |token|
      called_with = token
      { 'username' => 'aws-user', 'provider' => 'aws' }
    end

    aws_header = 'Credential=test/20260312/us-east-1//aws4_request, SignedHeaders=host;x-amz-date, Signature=9feb4616bf43b2f4471501d4543010ef8645572a3fbd4583f97a2137bf7abc48' # rubocop:disable Layout/LineLength
    @token_factory.expect(:get_adapter, token_adapter, ['AWS4-HMAC-SHA256'])

    result = @service.current("AWS4-HMAC-SHA256 #{aws_header}")
    assert_equal({ 'username' => 'aws-user', 'provider' => 'aws' }, result)
    assert_equal aws_header, called_with
  end
end
