require_relative '../../test_helper'
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
    login_client = Object.new
    verify_client = Object.new
    captured_params = nil

    login_client.define_singleton_method(:get_user) do
      Struct.new(:user).new(Struct.new(:user_name).new('test-user'))
    end

    verify_client.define_singleton_method(:get_user) do |params|
      captured_params = params
      true
    end

    clients = [verify_client, login_client]

    Aws::IAM::Client.stub(:new, ->(**_kwargs) { clients.shift }) do
      adapter = AwsIamAdapter.new
      assert adapter.verify_user_password('test-key', 'test-secret')
    end

    assert_equal({ user_name: 'test-user' }, captured_params)
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
