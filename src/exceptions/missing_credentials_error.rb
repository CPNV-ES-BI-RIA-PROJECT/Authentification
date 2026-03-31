require_relative 'application_error'

class MissingCredentialsError < ApplicationError
  STATUS = 500
  MESSAGE = 'Required credentials are missing'.freeze
end
