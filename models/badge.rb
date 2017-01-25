class Badge < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:name, :image]
  end

  many_to_one  :badge_group
  many_to_many :players
end
