module Observatory
  class ClassifyPlayerUpdateFrequency
    extend Resque::Plugins::JobStats

    @queue = :classify_player_update_frequency
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(player_id)
      player = Player[player_id]
      if player.nil?
        logger.error "No player with id #{ player_id.inspect }"
        return false
      end

      logger.info "Classifying update frequency of #{ player.inspect }"

      if player.player_data_points_dataset.count < 1
        logger.info "Not enough data to classify update frequency."
        return false
      end

      # We will compare it to #current_data.created_at, instead of Time.now.
      # This prevents the time difference from looking artifically big if the
      # classification job was delayed.
      # It does mean, however, that, if new player updates do not get
      # persisted, the player's classification will stay as-is.
      current_data = player.current_player_data_point
      # This might be the oldest point - which is always relevant.
      # It could also be #current_data, if that one changed.
      last_data_with_change = player.player_data_points_dataset.
        where(relevant: true).
        order(Sequel.desc(:created_at)).
        first

      # If the timestamps have a difference which can be represented as a
      # rational (e.g 2 hours), subtraction returned a rational representing
      # *hours* instead of the number of seconds.
      # Subtracting time objects seems to work.
      time_to_change = current_data.created_at.to_time - last_data_with_change.created_at.to_time
      logger.debug "Seconds since last change: #{ time_to_change }"

      # Find frequencies with big enough threshold, get lowest of them.
      f = UpdateFrequency.
        where(enabled: true).
        where { threshold >= time_to_change }.
        order(Sequel.asc(:threshold)).
        first

      unless f
        logger.info 'Player not active enough for any update frequency!'

        # Did not match any thresholds?
        f = UpdateFrequency.
          where(enabled: true, fallback: true).
          order(Sequel.asc(:threshold)).
          first

        if f
          logger.info "Assigning fallback frequency: '#{ f.name }'"
        else
          logger.info 'No fallback frequency found. Not changing anything.'
          return false
        end
      end

      logger.info "Classified as '#{ f.name }'"
      player.update_frequency = f
      player.next_update_at = current_data.created_at.to_time + f.interval
      player.save

      true
    end
  end
end
