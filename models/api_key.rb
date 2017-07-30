require 'securerandom'

class APIKey < Sequel::Model
  plugin :validation_helpers

  def validate
    validates_presence [:token, :key]
    validates_unique :token, :key
  end

  def self.active
    APIKey.where(active: true)
  end

  def self.inactive
    APIKey.where(active: false)
  end

  def self.authenticate(token, key)
    active.where(token: token, key: key).first
  end

  def self.generate
    api_key = APIKey.new(
      token: SecureRandom.uuid,
      key:   SecureRandom.hex(16)
    )

    while APIKey.where(token: api_key.token).count > 0
      api_key.token = SecureRandom.uuid
    end

    while APIKey.where(key: api_key.key).count > 0
      api_key.key = SecureRandom.hex(16)
    end

    api_key.save
  end
end
