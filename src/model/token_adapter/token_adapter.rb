class TokenAdapter
  def create(data)
    raise NotImplementedError, 'Subclasses must implement the create method'
  end

  def verify(token)
    raise NotImplementedError, 'Subclasses must implement the verify method'
  end

  def revoke(token)
    raise NotImplementedError, 'Subclasses must implement the revoke method'
  end
end
