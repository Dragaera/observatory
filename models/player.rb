class Player < Sequel::Model
  def self.from_player_data(data)
    player = Player.where(account_id: data.steam_id).first
    if player.nil?
      # Create new player if needed.
      player = Player.create(
        hive2_player_id: data.player_id,
        account_id:      data.steam_id,
        reinforced_tier: data.reinforced_tier
      )
    end

    # Add new data point based on current data.
    player_data = PlayerDataPoint.build_from_player_data_point(data, player_id: player.id)
    player.update(current_player_data_point: player_data)

    player
  end

  plugin :validation_helpers
  def validate
    validates_presence [:account_id, :hive2_player_id]
  end

  one_to_many :player_data_points
  many_to_one :current_player_data_point, class: :PlayerDataPoint, key: :current_player_data_point_id
  many_to_one :update_frequency

  def adagrad_sum
    return nil unless current_player_data_point
    current_player_data_point.adagrad_sum
  end

  def alias
    return nil unless current_player_data_point
    current_player_data_point.alias
  end

  def experience
    return nil unless current_player_data_point
    current_player_data_point.experience
  end

  def level
    return nil unless current_player_data_point
    current_player_data_point.level
  end

  def score
    return nil unless current_player_data_point
    current_player_data_point.score
  end

  def skill
    return nil unless current_player_data_point
    current_player_data_point.skill
  end

  def time_total
    return nil unless current_player_data_point
    current_player_data_point.time_total
  end

  def time_alien
    return nil unless current_player_data_point
    current_player_data_point.time_alien
  end

  def time_marine
    return nil unless current_player_data_point
    current_player_data_point.time_marine
  end

  def time_commander
    return nil unless current_player_data_point
    current_player_data_point.time_commander
  end

  def update_data(stalker: nil)
    stalker ||= HiveStalker::Stalker.new

    begin
      Observatory::RateLimit.log_get_player_data(type: :background)
      data = stalker.get_player_data(account_id)
      player_data = PlayerDataPoint.build_from_player_data_point(data, player_id: id)
      update(current_player_data_point: player_data)

      # Succesful updates will lead to reclassification.
      Resque.enqueue(Observatory::ClassifyPlayerUpdateFrequency, id)

      true
    rescue HiveStalker::APIError
      false
    ensure
      update(update_scheduled_at: nil)
    end
  end

  def async_update_data(random_delay: false)
    update(update_scheduled_at: Time.now)
    if random_delay
      delay = rand(Observatory::Config::PlayerData::BACKOFF_DELAY)
      Resque.enqueue_in(
        delay,
        Observatory::PlayerUpdate,
        id
      )

      delay
    else
      Resque.enqueue(Observatory::PlayerUpdate, id)
    end
  end

  # Retrieves recent distinct player data.  That is, if two entries are equal
  # (which is determined by whether total playtime changed), only the newest
  # will be returned.
  #
  # @param count [Fixnum] Number of entries which to return at most. `nil` in
  #   order to not limit entries.
  # @return [Array<PlayerDataPoint>]
  def recent_player_data(count = nil)
    out = []
    last_data = nil

    player_data_points_dataset.order_by(Sequel.desc(:created_at)).each do |data|
      if count && out.size >= count
        return out
      end

      if last_data.nil? || last_data.time_total != data.time_total
        out << data
      end
      last_data = data
    end

    out
  end

#   def graph_time_played_total
#     {
#       'Alien': time_alien,
#       'Marine': time_marine
#     }
#   end
# 
#   def graph_time_played
#     [
#       {
#         name: 'Alien',
#         data: player_data.map { |data| [data.created_at, data.time_alien] }
#       },
#       {
#         name: 'Marine',
#         data: player_data.map { |data| [data.created_at, data.time_marine] }
#       },
#     ]
#   end
# 
#   def graph_skill
#     player_data.map do |data|
#       [data.created_at, data.skill]
#     end
#   end
# 
#   def graph_experience_level
#     [
#       {
#         name: 'Experience',
#         data: player_data.map { |data| [data.created_at, data.experience] }
#       },
#       {
#         name: 'Level',
#         data: player_data.map { |data| [data.created_at, data.level] }
#       },
#     ]
#   end
end
