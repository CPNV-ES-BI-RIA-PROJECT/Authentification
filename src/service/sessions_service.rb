require_relative '../factory/iam_adapter_factory'
require_relative '../factory/token_adapter_factory'
require_relative '../exceptions/token/authorization_token_is_missing_error'
require_relative '../exceptions/token/invalid_token_format_error'

class SessionsService
  def initialize
    @iam_adapter_factory = IamAdapterFactory.new
    @token_adapter_factory = TokenAdapterFactory.new
  end

  def login(username, password, provider, token_provider)
    iam_adapter = @iam_adapter_factory.get_adapter(provider)
    iam_adapter.verify_user_password(username, password)
    token_adapter = @token_adapter_factory.get_adapter(token_provider)
    token_adapter.create({ username: username, provider: provider })
  end

  def current(token)
    token_adapter, token_value = parse_token(token)
    token_adapter.verify(token_value)
  end

  def logout(token)
    token_adapter, token_value = parse_token(token)
    token_adapter.revoke(token_value)
  end

  private

  def parse_token(token)
    raise AuthorizationTokenIsMissingError, 'Authorization token is missing' if token.nil? || token.empty?

    token_splitted = token.split(' ')
    raise InvalidTokenFormatError, 'Invalid token format' unless token_splitted.length == 2

    token_adapter = @token_adapter_factory.get_adapter(token_splitted[0])
    [token_adapter, token_splitted[1]]
  end
end
