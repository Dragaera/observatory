class Player < Sequel::Model
  def self.get_or_create(account_id: nil, steam_id: nil)
    unless account_id
      account_id = resolve_steam_id(steam_id)
    end

    if account_id.nil?
      return nil
    end

    p = Player.where(account_id: account_id).first
    unless p
      logger.debug("Creating new player with account_id: #{ account_id }")
      p = Player.create(
        account_id:     account_id,
        next_update_at: Time.now,
      )
      p.async_update_data
    end

    p
  end

  plugin :validation_helpers
  def validate
    validates_presence [:account_id]
  end

  plugin :pg_trgm

  one_to_many :player_data_points
  def _add_player_data_point(point)
    # Important to do this first, as equality check also checks `player_id`.
    point.player_id = id
    point.relevant = current_player_data_point != point

    if point.relevant
      point.save

      # Using `current_player_data_point` will *not* work, as that one checks
      # whether the current and new object are equal, and only updates if they
      # are not. 
      # Due to us overwriting PlayerData#==, this would lead to non-relevant
      # updates being discarded.
      update(current_player_data_point_id: point.id)
    else
      logger.debug "Discarding irrelevant player data point of player #{ point.player_id }"
      point.delete if point.exists?
      false
    end
  end

  many_to_one :current_player_data_point, class: :PlayerDataPoint, key: :current_player_data_point_id
  many_to_one :update_frequency
  many_to_many :badges
  one_to_many :player_data_exports

  # Returns list of players with stale data, who do not have an update
  # scheduled yet.
  #
  # @return [Sequel::Dataset] Players with stale data.
  def self.with_stale_data
    where { next_update_at <= Time.now }.where(update_scheduled_at: nil, enabled: true)
  end

  def self.by_account_id(id)
    where(account_id: id).first
  end

  def self.by_steam_id(steam_id)
    account_id = resolve_steam_id(steam_id)
    Player.by_account_id(account_id)
  end

  def self.by_current_alias(name = nil)
    result = Player.
      dataset.
      select(:account_id, :id).
      graph(
        :player_data_points,
        { Sequel[:players][:current_player_data_point_id] => Sequel[:player_data_points][:id] },
        join_type: :inner,
        select: [
          :alias,
          :level,
          :skill,
        ]
      )

    if name
      result.text_search(:alias, name)
    else
      result
    end
  end

  # Returns ranks of all players with regards to `cols` columns.
  #
  # Returned dataset will contain one hash-like object per player, containing
  # the player's ID, and one key - prefixed by `rank_` - per queried column.
  def self.ranks(cols)
    unless cols.is_a? Array
      cols = [cols]
    end

    PlayerDataPoint.
      where(id: Player.select(:current_player_data_point_id)).
      select {
        cols.map { |col| rank.function.over(order: Sequel.desc(col)).as("rank_#{ col }") } << :player_id
      }
  end

  def self.ranks_cache_key(player_id)
    "player:#{ player_id }:ranks"
  end

  def ranks_cache_key
    Player.ranks_cache_key(id)
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

  def steam_id
    SteamID::SteamID.new(account_id)
  end

  def update_data(stalker: nil)
    stalker ||= HiveStalker::Stalker.new

    begin
      Observatory::RateLimit::Hive.log_get_player_data(type: :background)
      data = stalker.get_player_data(account_id)
      player_data = PlayerDataPoint.build_from_player_data_point(data)

      # Needed so validations on `player_id` will pass.
      player_data.player_id = self.id
      if player_data.valid?
        # Overwritten to provide additional behaviour, see definition below.
        add_player_data_point(player_data)
        update_hive_badges(data)

        # TODO: Refactor this to use transaction-style block. `ensure` won't
        # work, as we reraise the caught exception.
        update(
          update_scheduled_at: nil,
          last_update_at:      Time.now,
          error_count:         0,
          error_message:       nil,
          enabled:             true,
        )

        # Succesful updates will lead to reclassification.
        # Enqueueing of this job happens after the update above, to prevent a
        # race condition where the new job might try to access fields which
        # (for new users) are not set, or (in the general case) not up-to-date.
        Resque.enqueue(Observatory::ClassifyPlayerUpdateFrequency, id)

        async_update_steam_badges

        true
      else
        # See `#validate` above, but essentially Hive account id = 0 & alias empty
        logger.warn "Ignoring invalid player data point of player #{ player_data.player_id }: #{ player_data.inspect }"
        update(
          update_scheduled_at: nil
        )

        false
      end
    rescue HiveStalker::APIError => e
      logger.error "Player update for player #{ id } failed: #{ e.message }"

      # Important to do this here, so we can calculate the `enabled` property.
      # to_i as it might be nil - and that'll give us a convenient 0.
      error_count = self.error_count.to_i + 1
      enabled = !!(current_player_data_point ||
        (error_count < Observatory::Config::Player::ERROR_THRESHOLD))
      update(
        update_scheduled_at: nil,
        error_count:         error_count,
        error_message:       e.message,
        enabled:             enabled,
      )
      raise
    end
  end

  def async_update_steam_badges(delay: nil)
    if delay
      Resque.enqueue_in(
        delay,
        Observatory::PlayerSteamUpdate,
        id
      )
    else
      Resque.enqueue(Observatory::PlayerSteamUpdate, id)
    end
  end

  def update_steam_badges
    Observatory::RateLimit::Steam.log_steam_query

    steam_inventory = Observatory::Steam::Inventory.new(self)
    if steam_inventory.badge_class_ids.empty?
      logger.info "No badges found, skipping..."
      return
    end

    Badge.where(key: steam_inventory.badge_class_ids, type: 'steam').each do |badge|
      safe_add_badge badge
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

  def rank(cols)
    Player.ranks(cols).
      from_self.
      where(player_id: id).
      first
  end

  def cached_ranks
    ranks = REDIS.hgetall(ranks_cache_key)

    if ranks.empty?
      ranks
    else
      {
        skill:            ranks.fetch('skill').to_i,
        score:            ranks.fetch('score').to_i,
        score_per_second: ranks.fetch('score_per_second').to_i,
        experience:       ranks.fetch('experience').to_i,
      }
    end
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

  def export_data(type: :csv)
    if type == :csv
      export = PlayerDataExport.create(
        player_id: id
      )
      export.async_create_csv

      export
    else
      raise ArgumentError, "Unknown type: #{ type.inspect }"
    end
  end

  def show_ensl_tutorials?
    Observatory::Config::Profile::ENSL::SHOW_TUTORIALS &&
      current_player_data_point &&
      time_total > Observatory::Config::Profile::ENSL::TIME_THRESHOLD &&
      skill < Observatory::Config::Profile::ENSL::SKILL_THRESHOLD
  end

  def rookie?
    return true unless current_player_data_point
    level < 20
  end

  def skill_tier_badge
    return SkillTierBadge.rookie if rookie?

    # NS2 supposedly uses the Adagrad sum to more determine a player's skil for
    # the tier assignment.
    # This likely serves to prevent flip-flopping between two different badges,
    # as you win/lose minor amounts of skill.
    player_skill = [0, skill - 25 / Math.sqrt(adagrad_sum)].max
    SkillTierBadge.
      where { hive_skill_threshold <= player_skill }.
      order_by(Sequel.desc(:hive_skill_threshold)).
      first
  end

  private
  def self.resolve_steam_id(steam_id)
    SteamID.from_string(steam_id, api_key: Observatory::Config::Steam::WEB_API_KEY).account_id
  rescue ArgumentError, WebApiError
    nil
  end

  def update_hive_badges(hive_data)
    hive_data.badges.each do |badge_key|
      badge = Badge.where(key: badge_key, type: 'hive').first
      if badge
        safe_add_badge badge
      else
        logger.error "Unknown badge key: #{ badge_key }"
      end
    end
  end

  def safe_add_badge(badge)
    if badge
      if badges.include?(badge)
        logger.info "Skipping existing badge #{ badge.name }"
      else
        logger.info "Adding new badge: #{ badge.name }"
        add_badge(badge)
      end
    else
      logger.error 'Badge must not be `nil`'
    end
  end
end
