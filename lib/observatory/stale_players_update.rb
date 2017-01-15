module Observatory
  class StalePlayersUpdate
    @queue = :stale_players_update

    def self.perform
      t = Time.now - Observatory::Config::PlayerData::UPDATE_INTERVAL * 60 * 60
      Player.where { updated_at < t }.each do |player|
        puts "Scheduling update for #{ player.inspect }"
        player.async_update_data
      end
    end
  end
end
