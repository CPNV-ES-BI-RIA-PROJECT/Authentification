class IamProviderAdapter
  def get_identity(identity_id)
    raise NotImplementedError, 'get_identity method must be implemented by subclass'
  end

  def validate_credentials(credentials)
    raise NotImplementedError, 'validate_credentials method must be implemented by subclass'
  end

  def create_credential(identity_id)
    raise NotImplementedError, 'create_credential method must be implemented by subclass'
  end

  def revoke_credential(credential_id)
    raise NotImplementedError, 'revoke_credential method must be implemented by subclass'
  end
end
