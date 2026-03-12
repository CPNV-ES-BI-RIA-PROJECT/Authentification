require 'aws-sdk-iam'
require_relative 'iam_adapter'
require_relative '../../exceptions/missing_credentials_error'

class AwsIamAdapter < IamProviderAdapter
  REQUIRED_ENV_VARS = %w[
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
  ].freeze

  def initialize
    super()
    unless validate_credentials
      raise MissingCredentialsError.new,
            'AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set for AWS IAM integration.'
    end

    region = ENV['AWS_REGION'] || 'us-east-1'
    credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @iam_client = Aws::IAM::Client.new(region: region, credentials: credentials)
  end

  def validate_credentials
    REQUIRED_ENV_VARS.all? { |var| ENV[var] && !ENV[var].empty? }
  end

  def verify_user_password(username, password)
    @iam_client.get_user({
                           access_key_id: username,
                           access_key_secret: password
                         })

    true
  rescue Aws::IAM::Errors::NoSuchEntity, Aws::IAM::Errors::AccessDenied
    false
  end
end
