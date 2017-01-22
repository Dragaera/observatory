module Observatory
  class StalePlayersUpdate
    @queue = :stale_players_update

    def self.perform
      Player.with_stale_data.each do |player|
        delay = rand(Observatory::Config::PlayerData::INITIAL_DELAY)
        logger.info "Scheduling update for #{ player.inspect } in #{ delay }s"
        player.async_update_data(delay: delay)
      end
    end
  end
end
