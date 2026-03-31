require_relative '../../test_helper'
require_relative '../../../src/model/token_adapter/token_adapter'

class TokenAdapterTest < Minitest::Test
  def setup
    @adapter = TokenAdapter.new
  end

  def test_create_raises_not_implemented_error
    error = assert_raises(NotImplementedError) { @adapter.create({}) }
    assert_equal 'Subclasses must implement the create method', error.message
  end

  def test_verify_raises_not_implemented_error
    error = assert_raises(NotImplementedError) { @adapter.verify('token') }
    assert_equal 'Subclasses must implement the verify method', error.message
  end

  def test_revoke_raises_not_implemented_error
    error = assert_raises(NotImplementedError) { @adapter.revoke('token') }
    assert_equal 'Subclasses must implement the revoke method', error.message
  end
end
