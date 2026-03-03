require 'minitest/autorun'
require 'ostruct'
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
    adapter = AwsIamAdapter.new
    assert adapter.validate_credentials, 'Expected credentials to be valid'
  end
end
