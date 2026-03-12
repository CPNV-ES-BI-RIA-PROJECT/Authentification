require_relative '../test_helper'
require_relative '../../src/factory/iam_adapter_factory'

class IamAdapterFactoryTest < Minitest::Test
  def setup
    @factory = IamAdapterFactory.new
  end

  def test_get_adapter_returns_aws_adapter_and_memoizes_it
    aws_adapter = Object.new
    AwsIamAdapter.stub(:new, aws_adapter) do
      first = @factory.get_adapter('AWS')
      second = @factory.get_adapter(:aws)
      assert_same aws_adapter, first
      assert_same first, second
    end
  end

  def test_get_adapter_returns_cognito_adapter_and_memoizes_it
    cognito_adapter = Object.new
    CognitoAwsIamAdapter.stub(:new, cognito_adapter) do
      first = @factory.get_adapter('Cognito')
      second = @factory.get_adapter(:cognito)
      assert_same cognito_adapter, first
      assert_same first, second
    end
  end

  def test_get_adapter_raises_for_unknown_type
    error = assert_raises(UnknownAdapterTypeError) { @factory.get_adapter('ldap') }
    assert_equal 'Unknown adapter type: ldap', error.message
  end
end
