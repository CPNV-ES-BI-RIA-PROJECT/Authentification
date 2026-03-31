require_relative 'token_error'

class InvalidTokenError < TokenError
  MESSAGE = 'Invalid token'.freeze
end
