require_relative '../model/iam_adapter/cognito_aws_iam_adapter'
require_relative '../model/iam_adapter/aws_iam_adapter'
require_relative '../model/iam_adapter/fake_iam_adapter'
require_relative '../exceptions/unknown_adapter_type_error'

class IamAdapterFactory
  def get_adapter(adapter_type)
    adapter_type = adapter_type.to_s.downcase.to_sym

    case adapter_type
    when :cognito
      return @cognito_adapter if @cognito_adapter

      @cognito_adapter ||= CognitoAwsIamAdapter.new
    when :fake
      return @fake_adapter if @fake_adapter

      @fake_adapter ||= FakeIamAdapter.new
    when :aws
      return @aws_adapter if @aws_adapter

      @aws_adapter ||= AwsIamAdapter.new
    else
      raise UnknownAdapterTypeError, "Unknown adapter type: #{adapter_type}"
    end
  end
end
