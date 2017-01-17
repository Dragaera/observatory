class PlayerDataPoint < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:alias, :score, :level, :experience, :skill, :time_total, :time_alien, :time_marine, :time_commander, :adagrad_sum, :player_id]
  end

  many_to_one :player

  def self.build_from_player_data_point(data, player_id: nil)
      data = PlayerDataPoint.new(
        # Sometimes the API returns `nil`.
        # Not fixing this in the client, as it's not equal to 0 / ''. But I need to
        # somehow handle it in the application.
        adagrad_sum:     data.adagrad_sum.to_f,
        alias:           data.alias.to_s,
        experience:      data.experience.to_i,
        level:           data.level.to_i,
        score:           data.score.to_i,
        skill:           data.skill.to_i,
        time_total:      data.time_total.to_i,
        time_alien:      data.time_alien.to_i,
        time_marine:     data.time_marine.to_i,
        time_commander:  data.time_commander.to_i,
      )

      if player_id
        data.player_id = player_id
        data.save
      end

      data
  end
end
