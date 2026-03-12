require_relative '../../test_helper'
require_relative '../../../src/model/iam_adapter/cognito_aws_iam_adapter'

class CognitoAwsIamAdapterTest < Minitest::Test
  def setup
    ENV['AWS_ACCESS_KEY_ID'] = 'test-key'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'test-secret'
    ENV['AWS_REGION'] = 'us-east-1'
    ENV['AWS_COGNITO_CLIENT_ID'] = 'test-client'
    ENV['AWS_COGNITO_USER_POOL_ID'] = 'test-pool'
  end

  def teardown
    ENV.delete('AWS_ACCESS_KEY_ID')
    ENV.delete('AWS_SECRET_ACCESS_KEY')
    ENV.delete('AWS_REGION')
    ENV.delete('AWS_COGNITO_CLIENT_ID')
    ENV.delete('AWS_COGNITO_USER_POOL_ID')
    ENV.delete('AWS_COGNITO_CLIENT_SECRET')
  end

  def test_validate_credentials
    client = Object.new
    Aws::CognitoIdentityProvider::Client.stub(:new, client) do
      adapter = CognitoAwsIamAdapter.new
      assert adapter.validate_credentials, 'Expected credentials to be valid'
    end
  end

  def test_verify_user_password_with_valid_credentials
    client = Object.new
    def client.admin_initiate_auth(*)
      { authentication_result: {} }
    end

    Aws::CognitoIdentityProvider::Client.stub(:new, client) do
      adapter = CognitoAwsIamAdapter.new
      assert adapter.verify_user_password('test-user', 'test-password'), 'Expected credentials to be verified'
    end
  end

  def test_verify_user_password_with_invalid_credentials
    client = Object.new
    def client.admin_initiate_auth(*)
      raise Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new(nil, 'not found')
    end

    Aws::CognitoIdentityProvider::Client.stub(:new, client) do
      adapter = CognitoAwsIamAdapter.new
      refute adapter.verify_user_password('invalid-user', 'invalid-password'),
             'Expected invalid credentials to return false'
    end
  end

  def test_verify_user_password_with_access_denied
    client = Object.new
    def client.admin_initiate_auth(*)
      raise Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new(nil, 'access denied')
    end

    Aws::CognitoIdentityProvider::Client.stub(:new, client) do
      adapter = CognitoAwsIamAdapter.new
      refute adapter.verify_user_password('invalid-user', 'invalid-password')
    end
  end

  def test_verify_user_password_includes_secret_hash_when_configured
    ENV['AWS_COGNITO_CLIENT_SECRET'] = 'client-secret'
    client = Object.new
    captured = {}
    client.define_singleton_method(:admin_initiate_auth) do |params|
      captured[:params] = params
      { authentication_result: {} }
    end

    Aws::CognitoIdentityProvider::Client.stub(:new, client) do
      adapter = CognitoAwsIamAdapter.new
      assert adapter.verify_user_password('test-user', 'test-password')
      assert captured[:params][:auth_parameters]['SECRET_HASH'],
             'Expected secret hash to be sent when client secret is configured'
    end
  end

  def test_initialize_raises_when_credentials_are_missing
    ENV.delete('AWS_ACCESS_KEY_ID')
    ENV.delete('AWS_SECRET_ACCESS_KEY')
    ENV.delete('AWS_COGNITO_CLIENT_ID')
    ENV.delete('AWS_COGNITO_USER_POOL_ID')

    error = assert_raises(MissingCredentialsError) { CognitoAwsIamAdapter.new }
    assert_match(/must be set/, error.message)
  end
end
