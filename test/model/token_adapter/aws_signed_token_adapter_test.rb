require_relative '../../test_helper'
require_relative '../../../src/model/token_adapter/aws_signed_token_adapter'
require_relative '../../../src/exceptions/token/invalid_token_error'

class DummyAwsIamAdapter
  def verify_user_password(_username, _password)
    true
  end
end

class InvalidAwsIamAdapter
  def verify_user_password(_username, _password)
    false
  end
end

class DummyIamAdapterFactory
  def initialize(adapter)
    @adapter = adapter
  end

  def get_adapter(_adapter_type)
    @adapter
  end
end

class AwsSignedTokenAdapterTest < Minitest::Test
  def setup
    iam_adapter_factory = DummyIamAdapterFactory.new(DummyAwsIamAdapter.new)
    IamAdapterFactory.stub(:new, iam_adapter_factory) do
      @adapter = AwsSignedTokenAdapter.new
    end
    @valid_header = 'Credential=test/20260312/us-east-1//aws4_request, SignedHeaders=host;x-amz-date, Signature=9feb4616bf43b2f4471501d4543010ef8645572a3fbd4583f97a2137bf7abc48' # rubocop:disable Layout/LineLength
  end

  def test_verify_returns_expected_payload
    result = @adapter.verify(@valid_header)

    assert_equal 'test', result['username']
    assert_equal 'aws', result['provider']
    assert_equal 'host;x-amz-date', result['signed_headers']
    assert_equal '9feb4616bf43b2f4471501d4543010ef8645572a3fbd4583f97a2137bf7abc48', result['signature']
    assert_equal 'test/20260312/us-east-1//aws4_request', result['credential']
  end

  def test_verify_raises_invalid_token_error_when_header_is_nil
    assert_raises(InvalidTokenError) { @adapter.verify(nil) }
  end

  def test_verify_raises_invalid_token_error_when_credential_is_missing
    header = 'SignedHeaders=host;x-amz-date, Signature=abc'
    assert_raises(InvalidTokenError) { @adapter.verify(header) }
  end

  def test_verify_raises_invalid_token_error_when_signature_is_missing
    header = 'Credential=test/20260312/us-east-1//aws4_request, SignedHeaders=host;x-amz-date'
    assert_raises(InvalidTokenError) { @adapter.verify(header) }
  end

  def test_verify_raises_invalid_token_error_when_signed_headers_are_missing
    header = 'Credential=test/20260312/us-east-1//aws4_request, Signature=9feb4616bf43b2f4471501d4543010ef8645572a3fbd4583f97a2137bf7abc48' # rubocop:disable Layout/LineLength
    assert_raises(InvalidTokenError) { @adapter.verify(header) }
  end

  def test_verify_raises_invalid_token_error_when_signature_is_malformed
    header = 'Credential=test/20260312/us-east-1//aws4_request, SignedHeaders=host;x-amz-date, Signature=shortsig'
    assert_raises(InvalidTokenError) { @adapter.verify(header) }
  end

  def test_verify_raises_invalid_token_error_when_credential_format_is_invalid
    header = 'Credential=test/20260312/us-east-1, SignedHeaders=host;x-amz-date, Signature=9feb4616bf43b2f4471501d4543010ef8645572a3fbd4583f97a2137bf7abc48' # rubocop:disable Layout/LineLength
    assert_raises(InvalidTokenError) { @adapter.verify(header) }
  end

  def test_create_raises_not_implemented_error
    error = assert_raises(NotImplementedError) { @adapter.create({}) }
    assert_equal 'AWS signed tokens are read-only and cannot be created', error.message
  end

  def test_verify_raises_invalid_token_error_when_credentials_invalid
    factory = DummyIamAdapterFactory.new(InvalidAwsIamAdapter.new)
    IamAdapterFactory.stub(:new, factory) do
      adapter = AwsSignedTokenAdapter.new
      error = assert_raises(InvalidTokenError) { adapter.verify(@valid_header) }
      assert_equal 'Invalid credential in AWS authorization header', error.message
    end
  end

  def test_validate_access_key_id_raises_invalid_token_error_when_missing
    error = assert_raises(InvalidTokenError) { @adapter.send(:validate_access_key_id, nil) }
    assert_equal 'Access key ID is missing from credential', error.message
  end

  def test_revoke_returns_nil
    assert_nil @adapter.revoke(@valid_header)
  end
end
