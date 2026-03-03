class IamProviderAdapter
  def verify_user_password(username, password)
    raise NotImplementedError, 'Subclasses must implement the verify_user_password method'
  end
end
