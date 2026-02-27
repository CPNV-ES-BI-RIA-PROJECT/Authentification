require_relative '../factory/sessions_adapter_factory'

class SessionsService
  def initialize
    @bucket_factory = SessionsAdapterFactory.new
  end
end
