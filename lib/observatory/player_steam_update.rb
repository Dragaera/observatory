module Observatory
  class PlayerSteamUpdate
    extend Resque::Plugins::JobStats

    @queue = :get_steam_data
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        logger.error "No player with id #{ player_id.inspect }"
        return false
      end

      if RateLimit::Steam.steam_query?
        player.update_steam_badges
      else
        delay = rand(Observatory::Config::PlayerData::BACKOFF_DELAY)
        player.async_update_steam_badges(delay: delay)
        logger.info "Rescheduling Steam query for #{ player_id } in #{ delay }s."

        false
      end
    end
  end
end
