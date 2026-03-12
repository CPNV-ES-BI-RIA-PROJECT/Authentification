require_relative '../model/token_adapter/aws_signed_token_adapter'
require_relative '../model/token_adapter/bearer_token_adapter'
require_relative '../exceptions/unknown_adapter_type_error'

class TokenAdapterFactory
  def get_adapter(adapter_type)
    adapter_type = adapter_type.to_s.downcase.to_sym
    case adapter_type
    when :bearer
      return @bearer_adapter if @bearer_adapter

      @bearer_adapter ||= BearerTokenAdapter.new
    when :'aws4-hmac-sha256'
      return @aws_signed_adapter if @aws_signed_adapter

      @aws_signed_adapter ||= AwsSignedTokenAdapter.new
    else
      raise UnknownAdapterTypeError, "Unknown adapter type: #{adapter_type}"
    end
  end
end
