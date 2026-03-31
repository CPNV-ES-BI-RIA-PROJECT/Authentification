require_relative 'iam_adapter'

class FakeIamAdapter < IamProviderAdapter
  def verify_user_password(username, password)
    return true if (username == 'user1' && password == 'password1') || (username == 'user2' && password == 'password2')

    false
  end
end
