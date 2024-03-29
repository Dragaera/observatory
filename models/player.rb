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
  # Adds new player data point if it contains relevant data, discards it otherwise.
  #
  # Returns `point` either way (behaviour of Sequel). `point.new?` will
  # indicate whether it was saved to the DB (new = false) or discarded (new =
  # true).
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
      # Sorty by similarity, with equally similar results being sorted by the
      # player's "last active at" date.
      result.
        text_search(:alias, name).
        order_append(Sequel.desc(Sequel[:player_data_points][:created_at]))
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

  def self.nsl_account_cache_key(player_id)
    "player:#{ player_id }:nsl_account"
  end

  def self.leaderboard_cache_key(type)
    "leaderboard:#{ type }"
  end


  def nsl_account_cache_key
    Player.nsl_account_cache_key(id)
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

  def score_offset
    return nil unless current_player_data_point
    current_player_data_point.score_offset
  end

  def score_per_second
    return nil unless current_player_data_point
    current_player_data_point.score_per_second
  end

  def score_per_second_field
    return nil unless current_player_data_point
    current_player_data_point.score_per_second_field
  end

  def apply_historical_score_compensation
    current_offset        = 0
    data_point_offset_map = {}

    # Loading it all into RAM for easy handling of consecutive slices. No
    # single player has a significant number of PDPs, so this is sensible
    # enough.
    data_points = player_data_points_dataset.
      order_by(Sequel.asc(:created_at)).
      to_a

    logger.info "Processing #{ data_points.length } player data points."

    # We first get a list of data points with a suspicious increase in store,
    # and remember which data points we need to update later.  Updating them
    # immediately would potentially cause issues as we would, in iteration `i`,
    # modify data which is looked at in iteration `i + 1`.
    data_points.each_cons(2) do |dt1, dt2|
      result = calculate_score_offset(old_pdp: dt1, new_pdp: dt2, old_offset: current_offset)

      # Result = nil implies no change needed.
      if result
        current_offset = result.fetch(:offset)
        data_point_offset_map[dt2.id] = result
      end
    end

    logger.info "Processing #{ data_point_offset_map.length } updates."
    data_points.each do |pdp|
      update = data_point_offset_map[pdp.id]
      if update
        offset                  = update.fetch(:offset)
        offset_changed          = update.fetch(:offset_changed)

        # As the full model is populated and loaded we can just call #update
        # which will - if it would not change any values - simply be a no-op.
        pdp.update(
          score_offset:         offset,
          score_offset_changed: offset_changed,
          # `pdp.score - pdp.score_offset`, is the original score, to which the
          # new offset is then added.
          score:                pdp.score - pdp.score_offset + offset,
        )
      end
    end

    # Mark that the processing of historical data has been performed
    update(score_offset_calculated: true)

    # And finally recalculate the rank cache
    update_leaderboard_cache
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
        old_pdp = current_player_data_point
        # Overwritten to provide additional behaviour, see definition below.
        new_pdp = add_player_data_point(player_data)

        update_hive_badges(data)

        # TODO: Refactor this to use transaction-style block. `ensure` won't
        # work, as we reraise the caught exception.
        update(
          update_scheduled_at: nil, # Update finished.
          next_update_at:      nil, # We don't know when the next update will be,
                                    # until the classification job has run.
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

        if !score_offset_calculated
          logger.warn 'Score offset for historical data not calculated yet, doing so now.'
          apply_historical_score_compensation
        elsif old_pdp && !new_pdp.new?
          # If the object is #new?, then it was not saved to the DB, ergo
          # discarded due to irrelevancy - in which case we needn't bother.

          # Ensure we're aware of potential default values set by the DB
          new_pdp.reload

          logger.info 'Calculating score offset using previous data point.'

          # old_offset is the base offset which the new one is based one.
          result         = calculate_score_offset(old_pdp: old_pdp, new_pdp: new_pdp, old_offset: old_pdp.score_offset)
          offset         = result.fetch(:offset)
          offset_changed = result.fetch(:offset_changed)
          # It being a new data point we definitely have to set an offset -
          # which might be zero.
          new_pdp.update(
            # No need to first recover the original score, it being a new data
            # point the existing offset is guaranteed to be `0`.
            score: new_pdp.score + offset,
            score_offset: offset,
            score_offset_changed: offset_changed,
          )
        else
          logger.info 'First data point, or new data point discarded, skipping score offset calculation.'
        end

        update_leaderboard_cache
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
      # We do *not* reset `next_update_at` here, as we want a new one to be
      # requeued, until they either succeed or the player is disabled.
      update(
        update_scheduled_at: nil, # No update is scheduled currently
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

  def update_leaderboard_cache
    logger.debug("Updating leaderboard cache of player #{ id }")
    if current_player_data_point.nil?
      # Players where eg the initial query failed will not have any known skill
      # etc values, and will not be included in the leaderboard.
      logger.debug("Player has no data, skipping.")
      return false
    end

    REDIS.zadd(Player.leaderboard_cache_key('skill'), skill, id)
    REDIS.zadd(Player.leaderboard_cache_key('score_per_second'), score_per_second, id)
    REDIS.zadd(Player.leaderboard_cache_key('score'), score, id)
    REDIS.zadd(Player.leaderboard_cache_key('level'), level, id)
    REDIS.zadd(Player.leaderboard_cache_key('experience'), experience, id)
    REDIS.zadd(Player.leaderboard_cache_key('time_total'), time_total, id)
    REDIS.zadd(Player.leaderboard_cache_key('time_alien'), time_alien, id)
    REDIS.zadd(Player.leaderboard_cache_key('time_marine'), time_marine, id)
    REDIS.zadd(Player.leaderboard_cache_key('time_commander'), time_commander, id)
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

  def cached_rank(type)
    redis_key = Player.leaderboard_cache_key(type)
    rank = REDIS.zrevrank(redis_key, id)
    if rank
      # Indices are 0-based, while our ranks start at 1
      rank + 1
    else
      nil
    end
  end

  def cached_nsl_account
    account = REDIS.hgetall(nsl_account_cache_key)

    if account.empty?
      nil
    else
      {
        nsl_id: account.fetch('nsl_id'),
        nsl_url: "#{ Observatory::Config::NSL::PROFILE_BASE_URL }/#{ account.fetch('nsl_id') }",
        nsl_name: account.fetch('nsl_name'),
      }
    end
  end

  # Return timestamp of the last time the player's data changed.
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
  rescue ArgumentError, SteamCondenser::Error::WebApi
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

  def calculate_score_offset(old_pdp:, new_pdp:, old_offset:)
    threshold = Observatory::Config::PlayerData::SCORE_PER_SECOND_THRESHOLD

    current_offset = old_offset
    offset_changed = false

    # Resetting to the original score (`.score - score_offset`) allows
    # later recalculating the offset using a new threshold.
    # Mind that new_pdp is just the *newer* of the two, not necessarily a *new*
    # one if it's used to eg process historical data.
    score_delta = (new_pdp.score - new_pdp.score_offset) - (old_pdp.score - old_pdp.score_offset)
    time_delta  = new_pdp.time_total - old_pdp.time_total

    score_per_second = score_delta.to_f / time_delta

    if score_per_second >= threshold
      logger.info "Score per second of #{ score_per_second } >= #{ threshold }: PDP #{ old_pdp.id } => #{ new_pdp.id } had score gain of #{ score_delta }"
      # As this pair of data point has also had a too high increase, we have to
      # increase the total offset (from now on) by the proper amount.  Note:
      # Offset will be negative in the usual case, as it's always something
      # which is *added* to the score.
      current_offset -= score_delta
      logger.debug "Offset is now: #{ current_offset }"
      offset_changed = true
    end

    return { offset: current_offset, offset_changed: offset_changed }
  end
end
