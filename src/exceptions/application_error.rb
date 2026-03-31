class ApplicationError < StandardError
  DEFAULT_STATUS = 500
  DEFAULT_MESSAGE = 'An unexpected error occurred'.freeze

  attr_reader :status

  def initialize(message = self.class.default_message, status: self.class.default_status)
    @status = status
    super(message)
  end

  def self.default_status
    const_defined?(:STATUS) ? self::STATUS : DEFAULT_STATUS
  end

  def self.default_message
    const_defined?(:MESSAGE) ? self::MESSAGE : DEFAULT_MESSAGE
  end
end
