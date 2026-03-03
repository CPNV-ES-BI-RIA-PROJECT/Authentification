require_relative 'iam_adapter'
require_relative '../../exceptions/missing_credentials_error'

class AwsIamAdapter < IamProviderAdapter
  def initialize
    super()
    unless validate_credentials
      raise MissingCredentialsError.new,
            'AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables must be set for AWS IAM integration.'
    end

    @region = ENV['AWS_REGION'] || 'us-east-1'
  end

  def validate_credentials
    !ENV['AWS_ACCESS_KEY_ID'].nil? && !ENV['AWS_SECRET_ACCESS_KEY'].nil?
  end
end
