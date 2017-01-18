class Player < Sequel::Model
  def self.get_or_create(account_id:)
    Player.where(account_id: account_id).first ||
      Player.create(account_id: account_id)
  end

  plugin :validation_helpers
  def validate
    validates_presence [:account_id]
  end

  one_to_many :player_data_points
  def _add_player_data_point(point)
    # Important to do this first, as equality check also checks `player_id`.
    point.player_id = id
    point.relevant = current_player_data_point != point
    point.save
  end

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

  def hive_player_id
    return nil unless current_player_data_point
    current_player_data_point.hive_player_id
  end

  def experience
    return nil unless current_player_data_point
    current_player_data_point.experience
  end

  def level
    return nil unless current_player_data_point
    current_player_data_point.level
  end

  def reinforced_tier
    return nil unless current_player_data_point
    current_player_data_point.reinforced_tier
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
      player_data = PlayerDataPoint.build_from_player_data_point(data)
      add_player_data_point(player_data)
      # Using `current_player_data_point` will *not* work, as that one checks
      # whether the current and new object are equal, and only updates if they
      # are not. 
      # Due to us overwriting PlayerData#==, this would lead to non-relevant
      # updates being discarded.
      update(current_player_data_point_id: player_data.id)

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
    player_data_points_dataset.where(relevant: true).
      order_by(Sequel.desc(:created_at)).
      limit(count)
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
