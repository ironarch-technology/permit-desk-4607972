require 'openssl'
require 'base64'

# Signed cookie payload for the portal. Accounts sign in at the counter or on
# the portal and carry this for the length of the session.
class SessionToken
  TTL = 30.minutes

  class << self
    def issue(account)
      payload = "#{account.id}:#{(Time.current + TTL).to_i}"
      "#{payload}:#{sign(payload)}"
    end

    def account_id(token)
      return nil if token.blank?

      id, expiry, signature = token.split(':')
      return nil if signature.nil?
      return nil unless ActiveSupport::SecurityUtils.secure_compare(signature, sign("#{id}:#{expiry}"))
      return nil if expiry.to_i <= Time.current.to_i

      id.to_i
    end

    def expires_at(token)
      _id, expiry, _signature = token.to_s.split(':')
      expiry.present? ? Time.zone.at(expiry.to_i) : nil
    end

    private

    def secret
      ENV['PORTAL_TOKEN_SECRET'] || 'mountport-portal-dev'
    end

    def sign(payload)
      Base64.urlsafe_encode64(OpenSSL::HMAC.digest('SHA256', secret, payload), padding: false)
    end
  end
end
