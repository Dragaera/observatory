require 'securerandom'

class APIKey < Sequel::Model
  plugin :validation_helpers

  def validate
    validates_presence [:token, :title]
    validates_unique :token
    validates_max_length 30, :title
  end

  def self.active
    APIKey.where(active: true)
  end

  def self.inactive
    APIKey.where(active: false)
  end

  def self.authenticate(token)
    active.where(token: token).first
  end

  def self.generate()
    api_key = APIKey.new(
      token: SecureRandom.hex(16)
    )

    while APIKey.where(token: api_key.token).count > 0
      api_key.token = SecureRandom.hex(16)
    end

    api_key
  end
end
