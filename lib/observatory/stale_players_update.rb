module Observatory
  class StalePlayersUpdate
    @queue = :stale_players_update

    def self.perform
      UpdateFrequency.each do |f|
        if f.enabled
          puts "Checking players with frequency '#{ f.name }'"
          t = Time.now - f.interval
          f.players_dataset.where(update_scheduled_at: nil).where { updated_at < t }.each do |player|
            puts "Scheduling update for #{ player.inspect }"
            player.async_update_data
          end
        else
          puts "Skipping check for disabled frequency '#{ f.name }'"
        end
      end
    end
  end
end
