class UpdateFrequency < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:name, :interval]
  end

  one_to_many :players
end
