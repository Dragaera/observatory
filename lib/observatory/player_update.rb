module Observatory
  class PlayerUpdate
    extend Resque::Plugins::JobStats

    @queue = :get_player_data
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        logger.error "No player with id #{ player_id.inspect }"
        return false
      end

      if RateLimit::Hive.get_player_data?(type: :background)
        player.update_data
      else
        delay = rand(Observatory::Config::PlayerData::BACKOFF_DELAY)
        player.async_update_data(delay: delay)
        logger.info "Rescheduling player update for #{ player_id } in #{ delay }s."

        false
      end
    end
  end
end
