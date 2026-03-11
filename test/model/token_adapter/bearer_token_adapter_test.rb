require 'jwt'
require 'securerandom'
require_relative '../../test_helper'
require_relative '../../../src/model/token_adapter/bearer_token_adapter'

class BearerTokenAdapterTest < Minitest::Test
  SECRET_FILE = BearerTokenAdapter::SECRET_FILE_PATH
  REVOKED_TOKENS_FILE = BearerTokenAdapter::REVOKED_TOKENS_FILE_PATH

  def setup
    ENV['JWT_EXPIRATION_TIME'] = '60'
    File.delete(REVOKED_TOKENS_FILE) if File.exist?(REVOKED_TOKENS_FILE)
    File.delete(SECRET_FILE) if File.exist?(SECRET_FILE)
    File.write(SECRET_FILE, "test_secret\n")
    @adapter = BearerTokenAdapter.new
  end

  def teardown
    ENV.delete('JWT_EXPIRATION_TIME')
    File.delete(REVOKED_TOKENS_FILE) if File.exist?(REVOKED_TOKENS_FILE)
    File.delete(SECRET_FILE) if File.exist?(SECRET_FILE)
  end

  def test_create_returns_bearer_token
    token = @adapter.create({ username: 'alice', provider: 'fake' })

    assert token.start_with?('Bearer ')
    encoded = token.split.last
    payload = JWT.decode(encoded, 'test_secret', true, { algorithm: 'HS256' })[0]
    assert_equal 'alice', payload['data']['username']
    assert_equal 'fake', payload['data']['provider']
  end

  def test_verify_returns_payload_data
    token = @adapter.create({ username: 'alice', provider: 'fake' }).split.last

    data = @adapter.verify(token)
    assert_equal({ 'username' => 'alice', 'provider' => 'fake' }, data)
  end

  def test_verify_raises_invalid_token_error_for_invalid_token
    assert_raises(InvalidTokenError) { @adapter.verify('not-a-token') }
  end

  def test_verify_raises_expired_token_error_for_expired_token
    payload = { data: { username: 'alice' }, exp: Time.now.to_i - 1 }
    expired_token = JWT.encode(payload, 'test_secret', 'HS256')

    assert_raises(ExpiredTokenError) { @adapter.verify(expired_token) }
  end

  def test_revoke_appends_token_and_verify_raises_revoked_token_error
    token = @adapter.create({ username: 'alice' }).split.last
    @adapter.revoke(token)

    assert_includes File.read(REVOKED_TOKENS_FILE), token
    assert_raises(RevokedTokenError) { @adapter.verify(token) }
  end

  def test_initialize_writes_secret_when_missing
    File.delete(SECRET_FILE) if File.exist?(SECRET_FILE)

    SecureRandom.stub :hex, 'stub-secret' do
      adapter = BearerTokenAdapter.new

      assert File.exist?(SECRET_FILE)
      assert_equal 'stub-secret', File.read(SECRET_FILE).strip
      assert_equal 'stub-secret', adapter.instance_variable_get(:@secret_key)
    end
  end
end
