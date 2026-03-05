require_relative '../../test_helper'
require_relative '../../../src/model/iam_adapter/iam_adapter'

class IamProviderAdapterTest < Minitest::Test
  def test_verify_user_password_raises_not_implemented_error
    adapter = IamProviderAdapter.new
    error = assert_raises(NotImplementedError) { adapter.verify_user_password('user', 'pass') }
    assert_equal 'Subclasses must implement the verify_user_password method', error.message
  end
end
