require_relative '../model/token_adapter/bearer_token_adapter'

class TokenAdapterFactory
  def get_adapter(adapter_type)
    adapter_type = adapter_type.to_s.downcase.to_sym
    case adapter_type
    when :bearer
      return @bearer_adapter if @bearer_adapter

      @bearer_adapter ||= BearerTokenAdapter.new
    else
      raise UnknownAdapterTypeError, "Unknown adapter type: #{adapter_type}"
    end
  end
end
