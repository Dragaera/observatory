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

      player.update_steam_badges
    end
  end
end
