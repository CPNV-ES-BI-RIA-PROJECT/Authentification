require 'aws-sdk-cognitoidentityprovider'
require 'base64'
require 'openssl'
require_relative 'iam_adapter'
require_relative '../../exceptions/missing_credentials_error'

class AwsIamAdapter < IamProviderAdapter
  REQUIRED_ENV_VARS = %w[
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_COGNITO_CLIENT_ID
    AWS_COGNITO_USER_POOL_ID
  ].freeze

  def initialize
    super()
    unless validate_credentials
      raise MissingCredentialsError.new,
            'AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_COGNITO_CLIENT_ID, and AWS_COGNITO_USER_POOL_ID must be set
            for AWS Cognito integration.'
    end

    region = ENV['AWS_REGION'] || 'us-east-1'
    credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])

    @client_id = ENV['AWS_COGNITO_CLIENT_ID']
    @user_pool_id = ENV['AWS_COGNITO_USER_POOL_ID']
    @client_secret = ENV['AWS_COGNITO_CLIENT_SECRET']
    @cognito_client = Aws::CognitoIdentityProvider::Client.new(region: region, credentials: credentials)
  end

  def validate_credentials
    REQUIRED_ENV_VARS.all? { |var| ENV[var] && !ENV[var].empty? }
  end

  def verify_user_password(username, password)
    auth_parameters = {
      'USERNAME' => username,
      'PASSWORD' => password
    }
    auth_parameters['SECRET_HASH'] = compute_secret_hash(username) if @client_secret

    @cognito_client.admin_initiate_auth(
      user_pool_id: @user_pool_id,
      client_id: @client_id,
      auth_flow: 'ADMIN_USER_PASSWORD_AUTH',
      auth_parameters: auth_parameters
    )
    true
  rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException,
         Aws::CognitoIdentityProvider::Errors::UserNotFoundException,
         Aws::CognitoIdentityProvider::Errors::UserNotConfirmedException,
         Aws::CognitoIdentityProvider::Errors::PasswordResetRequiredException
    false
  end

  private

  def compute_secret_hash(username)
    digest = OpenSSL::HMAC.digest('sha256', @client_secret, "#{username}#{@client_id}")
    Base64.strict_encode64(digest)
  end
end
