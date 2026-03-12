require 'minitest/mock'
require_relative '../../../src/model/iam_adapter/aws_iam_adapter'

class AwsIamAdapterTest < Minitest::Test
  def setup
    ENV['AWS_ACCESS_KEY_ID'] = 'test-key'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'test-secret'
    ENV['AWS_REGION'] = 'us-east-1'
  end

  def teardown
    ENV.delete('AWS_ACCESS_KEY_ID')
    ENV.delete('AWS_SECRET_ACCESS_KEY')
    ENV.delete('AWS_REGION')
  end

  def test_validate_credentials
    client = Object.new
    Aws::IAM::Client.stub(:new, client) do
      adapter = AwsIamAdapter.new
      assert adapter.validate_credentials, 'Expected credentials to be valid'
    end
  end

  def test_verify_user_password_with_valid_credentials
    client = Object.new
    def client.get_user(*)
      { user: { password_last_used: '2025-03-12T11:00:00Z' } }
    end

    Aws::IAM::Client.stub(:new, client) do
      adapter = AwsIamAdapter.new
      assert adapter.verify_user_password('test-key', 'test-secret')
    end
  end

  def test_verify_user_password_with_invalid_credentials
    client = Object.new
    def client.get_user(*)
      raise Aws::IAM::Errors::NoSuchEntity.new(nil, 'not found')
    end

    Aws::IAM::Client.stub(:new, client) do
      adapter = AwsIamAdapter.new
      refute adapter.verify_user_password('invalid-user', 'invalid-password')
    end
  end

  def test_verify_user_password_with_access_denied
    client = Object.new
    def client.get_user(*)
      raise Aws::IAM::Errors::AccessDenied.new(nil, 'access denied')
    end

    Aws::IAM::Client.stub(:new, client) do
      adapter = AwsIamAdapter.new
      refute adapter.verify_user_password('unauthorized-user', 'password')
    end
  end

  def test_initialize_raises_when_credentials_are_missing
    ENV.delete('AWS_ACCESS_KEY_ID')
    ENV.delete('AWS_SECRET_ACCESS_KEY')

    error = assert_raises(MissingCredentialsError) { AwsIamAdapter.new }
    assert_match(/must be set/, error.message)
  end
end
