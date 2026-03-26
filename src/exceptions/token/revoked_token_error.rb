require_relative 'token_error'

class RevokedTokenError < TokenError
  MESSAGE = 'Token has been revoked'.freeze
end
