class PlayerData < Sequel::Model(:player_data)
  plugin :validation_helpers
  def validate
    validates_presence [:alias, :score, :level, :experience, :skill, :time_total, :time_alien, :time_marine, :time_commander, :adagrad_sum, :player_id]
  end

  many_to_one :player

  def self.build_from_player_data(data, player_id: nil)
      data = PlayerData.new(
        adagrad_sum:     data.adagrad_sum,
        alias:           data.alias,
        experience:      data.experience,
        level:           data.level,
        score:           data.score,
        skill:           data.skill,
        time_total:      data.time_total,
        time_alien:      data.time_alien,
        time_marine:     data.time_marine,
        time_commander:  data.time_commander,
      )

      if player_id
        data.player_id = player_id
        data.save
      end

      data
  end
end
