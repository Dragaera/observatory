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

    # Using `current_player_data_point` will *not* work, as that one checks
    # whether the current and new object are equal, and only updates if they
    # are not. 
    # Due to us overwriting PlayerData#==, this would lead to non-relevant
    # updates being discarded.
    update(current_player_data_point_id: point.id)

  end

  many_to_one :current_player_data_point, class: :PlayerDataPoint, key: :current_player_data_point_id
  many_to_one :update_frequency
  many_to_many :badges

  # Returns list of players with stale data, who do not have an update
  # scheduled yet.
  #
  # @return [Sequel::Dataset] Players with stale data.
  def self.with_stale_data
    where { next_update_at <= Time.now }.where(update_scheduled_at: nil)
  end

  def self.by_account_id(id)
    where(account_id: id)
  end

  def self.by_current_alias(name)
    ids = graph(:player_data_points, {:players__current_player_data_point_id => :player_data_points__id}, join_type: :inner).
      select(:players__id).
      where(Sequel.ilike(:alias, "%#{ name }%")).
      distinct(:players__id).
      map(&:id)

    Player.where(id: ids)
  end

  def self.by_any_alias(name)
    ids = graph(:player_data_points, {:players__id => :player_data_points__player_id}, join_type: :inner).
      select(:players__id).
      where(Sequel.ilike(:alias, "%#{ name }%")).
      distinct(:players__id).
      map(&:id)

    Player.where(id: ids)
  end

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

  def score_per_second
    return nil unless current_player_data_point
    current_player_data_point.score_per_second
  end

  def score_per_second_field
    return nil unless current_player_data_point
    current_player_data_point.score_per_second_field
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

      data.badges.each do |badge_key|
        badge = Badge.where(key: badge_key).first
        if badge
          if badges.include?(badge)
            logger.info "Skipping existing badge #{ badge.name }"
          else
            logger.info "Adding new badge: #{ badge.name }"
            add_badge(badge)
          end
        else
          logger.error "Unknown badge key: #{ badge_key }"
        end
      end

      # Succesful updates will lead to reclassification.
      Resque.enqueue(Observatory::ClassifyPlayerUpdateFrequency, id)
      # TODO: Refactor this to use transaction-style block. `ensure` won't
      # work, as we reraise the caught exception.
      update(update_scheduled_at: nil)

      true
    rescue HiveStalker::APIError
      update(update_scheduled_at: nil)
      raise
    end
  end

  def async_update_data(delay: nil)
    update(update_scheduled_at: Time.now)
    if delay
      Resque.enqueue_in(
        delay,
        Observatory::PlayerUpdate,
        id
      )
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

  def rank(col)
    Player.
      # Inner join essential, as there can be players without data (e.g.
      # freshly added), which would otherwise be included in the join, which
      # will then throw off the ranking. (NULL > number, I guess?)
      graph(:player_data_points, [player_data_points__id: :current_player_data_point_id], join_type: :inner).
      select { [
        rank.function.over(order: Sequel.desc(col)),
        :players__id
      ] }.
      all.
      select { |hsh| hsh[:id] == id }.
      first[:rank]
  end

  # Return timestamp of last time player's data changed.
  def last_activity
    relevant_data = player_data_points_dataset.
      where(relevant: true).
      order(Sequel.desc(:created_at)).
      first

    if relevant_data
      relevant_data.created_at
    else
      nil
    end
  end
end
