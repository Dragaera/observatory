class PlayerDataPoint < Sequel::Model
  alias_method :relevant?, :relevant

  plugin :validation_helpers
  def validate
    validates_presence [:alias, :score, :level, :experience, :skill, :time_total, :time_alien, :time_marine, :time_commander, :adagrad_sum, :player_id, :hive_player_id, :score_per_second, :score_per_second_field]
  end

  def before_validation
    # If those are not specified we won't do anything. It will not pass
    # validation anyway.
    if [time_total, time_commander, score].all?
      if time_total == 0 || time_total == time_commander
        self.score_per_second       = 0
        self.score_per_second_field = 0
      else
        self.score_per_second       = score.to_f / time_total
        self.score_per_second_field = score.to_f / (time_total - time_commander)
      end

      super
    end
  end

  many_to_one :player

  def self.build_from_player_data_point(data)
      PlayerDataPoint.new(
        # Sometimes the API returns `nil`.
        # Not fixing this in the client, as it's not equal to 0 / ''. But I need to
        # somehow handle it in the application.
        adagrad_sum:     data.adagrad_sum.to_f,
        alias:           data.alias.to_s,
        experience:      data.experience.to_i,
        hive_player_id:  data.player_id,
        level:           data.level.to_i,
        reinforced_tier: data.reinforced_tier,
        score:           data.score.to_i,
        skill:           data.skill.to_i,
        time_total:      data.time_total.to_i,
        time_alien:      data.time_alien.to_i,
        time_marine:     data.time_marine.to_i,
        time_commander:  data.time_commander.to_i,
      )
  end

  def ==(other)
    self.alias == other.alias &&
      self.score == other.score &&
      self.level == other.level &&
      self.experience == other.experience &&
      self.skill == other.skill &&
      self.time_total == other.time_total &&
      self.time_alien == other.time_alien &&
      self.time_marine == other.time_marine &&
      self.time_commander == other.time_commander &&
      self.adagrad_sum == other.adagrad_sum &&
      self.player_id == other.player_id &&
      self.hive_player_id == other.hive_player_id
  end
end
