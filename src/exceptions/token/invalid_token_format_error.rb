require_relative 'token_error'

class InvalidTokenFormatError < TokenError
  MESSAGE = 'Invalid token format'.freeze
end
