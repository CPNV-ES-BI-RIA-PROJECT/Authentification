require_relative 'token_error'

class ExpiredTokenError < TokenError
  MESSAGE = 'Token has expired'.freeze
end
