require_relative 'application_error'

class UnknownAdapterTypeError < ApplicationError
  STATUS = 400
  MESSAGE = 'Unknown adapter type'.freeze
end
