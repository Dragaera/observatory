module Observatory
  class StalePlayersUpdate
    @queue = :stale_players_update

    def self.perform
      t = Time.now - Observatory::Config::PLAYER_UPDATE_INTERVAL * 60 * 60
      Player.where { created_at < t }.each do |player|
        player.async_update_data
      end
    end
  end
end
