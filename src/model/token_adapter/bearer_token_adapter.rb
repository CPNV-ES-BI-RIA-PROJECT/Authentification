require 'jwt'
require_relative '../../exceptions/token/expired_token_error'
require_relative '../../exceptions/token/revoked_token_error'
require_relative '../../exceptions/token/invalid_token_error'

class BearerTokenAdapter
  def initialize
    @expiration_time = (ENV['JWT_EXPIRATION_TIME'] || 3600).to_i
    @random_key = SecureRandom.hex(32)
    @secret_key = if File.exist?('storages/secret')
                    File.read('storages/secret').strip
                  else
                    (File.write('storages/secret', @random_key)
                     @random_key)
                  end
  end

  def create(data)
    payload = {
      data: data,
      exp: Time.now.to_i + @expiration_time
    }
    "Bearer #{JWT.encode(payload, @secret_key, 'HS256')}"
  end

  def verify(token)
    decoded_token = decode_and_validate(token)
    decoded_token[0]['data']
  end

  def revoke(token)
    decode_and_validate(token)
    File.open('storages/revoked_tokens', 'a') { |file| file.puts(token) }
    nil
  end

  private

  def decode_and_validate(token)
    decoded_token = JWT.decode(token, @secret_key, true, { algorithm: 'HS256', verify_expiration: false })
    raise ExpiredTokenError, 'Token has expired' if decoded_token[0]['exp'] < Time.now.to_i
    raise RevokedTokenError, 'Token has been revoked' if revoked_tokens.include?(token)

    decoded_token
  rescue JWT::DecodeError => e
    raise InvalidTokenError, "Invalid token: #{e.message}"
  end

  def revoked_tokens
    return [] unless File.exist?('storages/revoked_tokens')

    File.read('storages/revoked_tokens').split("\n")
  end
end
