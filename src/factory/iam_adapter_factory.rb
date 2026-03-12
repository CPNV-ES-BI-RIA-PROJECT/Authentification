require_relative '../model/iam_adapter/cognito_aws_iam_adapter'
require_relative '../exceptions/unknown_adapter_type_error'

class IamAdapterFactory
  def get_adapter(adapter_type)
    adapter_type = adapter_type.to_s.downcase.to_sym

    case adapter_type
    when :aws
      return @aws_adapter if @aws_adapter

      @aws_adapter ||= AwsIamAdapter.new
    else
      raise UnknownAdapterTypeError, "Unknown adapter type: #{adapter_type}"
    end
  end
end
