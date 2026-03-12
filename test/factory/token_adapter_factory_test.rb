require_relative '../test_helper'
require_relative '../../src/factory/token_adapter_factory'

class TokenAdapterFactoryTest < Minitest::Test
  def setup
    @factory = TokenAdapterFactory.new
  end

  def test_get_adapter_returns_bearer_adapter_and_memoizes_it
    adapter = Object.new
    BearerTokenAdapter.stub(:new, adapter) do
      first = @factory.get_adapter('BeArEr')
      second = @factory.get_adapter(:bearer)
      assert_same adapter, first
      assert_same first, second
    end
  end

  def test_get_adapter_returns_aws_signed_adapter_and_memoizes_it
    adapter = Object.new
    AwsSignedTokenAdapter.stub(:new, adapter) do
      first = @factory.get_adapter('AWS4-HMAC-SHA256')
      second = @factory.get_adapter('aws4-hmac-sha256')
      assert_same adapter, first
      assert_same first, second
    end
  end

  def test_get_adapter_raises_for_unknown_type
    error = assert_raises(UnknownAdapterTypeError) { @factory.get_adapter('jwt') }
    assert_equal 'Unknown adapter type: jwt', error.message
  end
end
