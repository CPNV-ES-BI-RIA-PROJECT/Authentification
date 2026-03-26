require_relative 'application_error'

class InvalidCredentialsError < ApplicationError
  STATUS = 401
  MESSAGE = 'Invalid credentials provided'.freeze
end
