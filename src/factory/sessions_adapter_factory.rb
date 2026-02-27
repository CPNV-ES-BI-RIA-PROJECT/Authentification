require_relative '../model/iam_adapter/aws_iam_provider_adapter'

class SessionsAdapterFactory
  def get_adapter(adapter_type)
    case adapter_type
    when :aws
      return @aws_adapter if @aws_adapter

      @aws_adapter ||= AwsBucketAdapter.new
    else
      raise UnknownAdapterTypeError, "Unknown adapter type: #{adapter_type}"
    end
  end
end
