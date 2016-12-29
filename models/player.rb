class Player < Sequel::Model
  def self.from_player_data(data)
    player = Player.where(account_id: data.steam_id).first
    if player.nil?
      player = Player.create(
        hive2_player_id: data.player_id,
        account_id:      data.steam_id,
        reinforced_tier: data.reinforced_tier
      )

      player_data = PlayerData.create(
        player_id:       player.id,
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

      player.update(current_player_data: player_data)

      player
    end

    player
  end

  plugin :validation_helpers
  def validate
    validates_presence [:account_id, :hive2_player_id]
  end

  one_to_many :player_data,         class: :PlayerData
  many_to_one :current_player_data, class: :PlayerData, key: :current_player_data_id

  def adagrad_sum
    return nil unless current_player_data
    current_player_data.adagrad_sum
  end

  def alias
    return nil unless current_player_data
    current_player_data.alias
  end

  def experience
    return nil unless current_player_data
    current_player_data.experience
  end

  def level
    return nil unless current_player_data
    current_player_data.level
  end

  def score
    return nil unless current_player_data
    current_player_data.score
  end

  def skill
    return nil unless current_player_data
    current_player_data.skill
  end

  def time_total
    return nil unless current_player_data
    current_player_data.time_total
  end

  def time_alien
    return nil unless current_player_data
    current_player_data.time_alien
  end

  def time_marine
    return nil unless current_player_data
    current_player_data.time_marine
  end

  def time_commander
    return nil unless current_player_data
    current_player_data.time_commander
  end
end
