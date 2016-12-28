class Player < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:account_id, :hive2_player_id]
  end
end
