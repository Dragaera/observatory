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

      # This will be the most current point with changed data. (Which - for
      # active players - will also be the one referenced in
      # #current_player_data - but for legacy players that one might be an
      # irrelevant point.
      last_data_with_change = player.player_data_points_dataset.
        where(relevant: true).
        order(Sequel.desc(:created_at)).
        first

      # If the timestamps have a difference which can be represented as a
      # rational (e.g 2 hours), subtraction returned a rational representing
      # *hours* instead of the number of seconds.
      # Subtracting time objects seems to work.
      time_to_change = player.last_update_at.to_time - last_data_with_change.created_at.to_time
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
      # Scheduling the next update based on when the current update happened -
      # as opposed to when it *should* have happened - ensures that, if updates
      # are delayed (due to eg rate limiting), future updates are being spread
      # out automatically.
      # It also prevents to have less than the desired interval between updates
      # of a player.
      player.next_update_at = Time.now + f.interval
      player.save

      true
    end
  end
end
