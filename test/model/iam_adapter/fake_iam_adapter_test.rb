require_relative '../../../src/model/iam_adapter/fake_iam_adapter'

class FakeIamAdapterTest < Minitest::Test
  def setup
    @adapter = FakeIamAdapter.new
  end

  def test_verify_user_password_returns_true_for_user1
    user1 = 'user1'
    password1 = 'password1'
    assert @adapter.verify_user_password(user1, password1)
  end

  def test_verify_user_password_returns_true_for_user2
    user2 = 'user2'
    password2 = 'password2'
    assert @adapter.verify_user_password(user2, password2)
  end

  def test_verify_user_password_returns_false_for_unknown_credentials
    unknown = 'unknown'
    secret = 'secret'
    refute @adapter.verify_user_password(unknown, secret)
  end
end
