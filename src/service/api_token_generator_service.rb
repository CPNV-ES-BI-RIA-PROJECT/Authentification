require_relative '../factory/token_adapter_factory'

class APITokenGeneratorService
  def initialize
    @token_adapter_factory = TokenAdapterFactory.new
  end

  def generate_api_token
    @token_adapter_factory.get_adapter(ENV['TOKEN_PROVIDER'] || 'jwt').create({ type: 'api' })
  end
end
