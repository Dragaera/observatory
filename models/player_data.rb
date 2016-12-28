class PlayerData < Sequel::Model(:player_data)
  plugin :validation_helpers
  def validate
    validates_presence [:alias, :score, :level, :experience, :skill, :time_total, :time_alien, :time_marine, :time_commander, :adagrad_sum, :player_id]
  end
end
