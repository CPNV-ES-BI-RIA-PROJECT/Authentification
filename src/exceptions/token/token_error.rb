require_relative '../application_error'

class TokenError < ApplicationError
  STATUS = 401
  MESSAGE = 'Token error'.freeze
end
