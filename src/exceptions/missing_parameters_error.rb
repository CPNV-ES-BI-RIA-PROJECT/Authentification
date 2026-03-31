require_relative 'application_error'

class MissingParametersError < ApplicationError
  STATUS = 400
  MESSAGE = 'Missing required parameters'.freeze
end
