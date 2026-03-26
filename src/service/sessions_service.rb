require_relative '../factory/iam_adapter_factory'
require_relative '../factory/token_adapter_factory'
require_relative '../exceptions/token/authorization_token_is_missing_error'
require_relative '../exceptions/token/invalid_token_format_error'
require_relative '../exceptions/invalid_credentials_error'

class SessionsService
  def initialize
    @iam_adapter_factory = IamAdapterFactory.new
    @token_adapter_factory = TokenAdapterFactory.new
  end

  def login(username, password)
    iam_adapter = @iam_adapter_factory.get_adapter(ENV['IAM_PROVIDER'] || 'cognito')
    unless iam_adapter.verify_user_password(username, password)
      raise InvalidCredentialsError, 'Invalid username or password'
    end

    token_adapter = @token_adapter_factory.get_adapter(ENV['TOKEN_PROVIDER'] || 'bearer')
    token_adapter.create({ username: username, provider: ENV['IAM_PROVIDER'] || 'cognito' })
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

    adapter_type, token_value = token.strip.split(' ', 2)
    unless adapter_type && token_value && !token_value.strip.empty?
      raise InvalidTokenFormatError, 'Invalid token format'
    end

    token_adapter = @token_adapter_factory.get_adapter(adapter_type)
    [token_adapter, token_value.strip]
  end
end
