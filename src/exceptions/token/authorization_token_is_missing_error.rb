require_relative 'token_error'

class AuthorizationTokenIsMissingError < TokenError
  MESSAGE = 'Authorization token is missing'.freeze
end
