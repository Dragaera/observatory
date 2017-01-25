class BadgeGroup < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:name]
  end

  one_to_many :badges
end
