require_relative 'token_adapter'
require_relative '../../exceptions/token/invalid_token_error'

class AwsSignedTokenAdapter < TokenAdapter
  def initialize
    super
    @iam_adapter = IamAdapterFactory.new.get_adapter(ENV['IAM_PROVIDER'] || 'cognito')
  end

  def create(_data)
    raise NotImplementedError, 'AWS signed tokens are read-only and cannot be created'
  end

  def verify(token)
    parsed = parse_authorization_header(token)

    unless @iam_adapter.verify_user_password(parsed[:access_key_id], parsed[:secret_access_key])
      raise InvalidTokenError, 'Invalid credential in AWS authorization header'
    end

    {
      'username' => parsed[:access_key_id],
      'provider' => 'aws',
      'signed_headers' => parsed[:signed_headers],
      'signature' => parsed[:signature],
      'credential' => parsed[:credential]
    }
  end

  def revoke(_token)
    nil
  end

  private

  def parse_authorization_header(token)
    validate_token_presence(token)

    parts = token.split(',').map(&:strip)
    params = parts.each_with_object({}) do |segment, memo|
      key, value = segment.split('=', 2)
      memo[key.downcase.to_sym] = value if key && value
    end

    credential = params[:credential]
    signature = params[:signature]
    signed_headers = params[:signedheaders]

    validate_credential(credential)
    validate_signature(signature)
    validate_signature_format(signature)
    validate_signed_headers(signed_headers)

    splited_credential = credential.split('/')

    access_key_id = splited_credential.first
    validate_access_key_id(access_key_id)
    validate_credential_format(credential)

    secret_access_key = splited_credential[1]

    {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      signed_headers: signed_headers,
      signature: signature,
      credential: credential
    }
  end

  def validate_token_presence(token)
    raise InvalidTokenError, 'Invalid AWS authorization header' if token.nil? || token.strip.empty?
  end

  def validate_credential(credential)
    return if credential && !credential.empty?

    raise InvalidTokenError, 'Credential is missing from AWS authorization header'
  end

  def validate_signature(signature)
    return if signature && !signature.empty?

    raise InvalidTokenError, 'Signature is missing from AWS authorization header'
  end

  def validate_signature_format(signature)
    return if signature =~ /\A[0-9a-f]{64}\z/

    raise InvalidTokenError, 'Signature is invalid'
  end

  def validate_signed_headers(headers)
    return if headers && !headers.empty?

    raise InvalidTokenError, 'Signed headers are missing from AWS authorization header'
  end

  def validate_access_key_id(access_key_id)
    return if access_key_id && !access_key_id.empty?

    raise InvalidTokenError, 'Access key ID is missing from credential'
  end

  def validate_credential_format(credential)
    parts = credential.split('/')
    return if parts.length >= 5 && parts.last == 'aws4_request'

    raise InvalidTokenError, 'Credential format is invalid'
  end
end
