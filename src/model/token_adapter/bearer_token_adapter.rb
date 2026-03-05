require 'jwt'
require_relative '../../exceptions/token/expired_token_error'
require_relative '../../exceptions/token/revoked_token_error'
require_relative '../../exceptions/token/invalid_token_error'

class BearerTokenAdapter
  def initialize
    @secret_key = ENV['JWT_SECRET_KEY'] || 'default_secret_key'
    @expiration_time = (ENV['JWT_EXPIRATION_TIME'] || 3600).to_i
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
    File.open('storages/revoked_tokens.txt', 'a') { |file| file.puts(token) }
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
    return [] unless File.exist?('storages/revoked_tokens.txt')

    File.read('storages/revoked_tokens.txt').split("\n")
  end
end
