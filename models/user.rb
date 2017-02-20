class User < Sequel::Model
  plugin :validation_helpers

  def self.active
    User.where(active: true)
  end

  def self.inactive
    User.where(active: false)
  end

  def self.authenticate(user, password)
    matching_user = active.where(user: user).first

    if matching_user && matching_user.password == password
      matching_user
    end
  end

  def validate
    validates_presence [:user, :password]
    validates_unique :user
  end

  def password
    hash = super
    if hash.nil?
      hash
    else
      BCrypt::Password.new(super)
    end
  end

  def password=(val)
    if val.nil? || val.empty?
      super(nil)
    else
      super(BCrypt::Password.create(val).to_s)
    end
  end
end
