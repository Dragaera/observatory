module Observatory
  class PlayerUpdate
    @queue = :get_player_data

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        puts "No player with id #{ player_id } (#{ player_id.to_i })"
        return false
      end

      # TODO: This will potentially block all workers.
      # Should have some way to retry later. Resque-scheduler delayed job?
      RateLimit.rate_limit.exec_within_threshold('hive.total', threshold: 1, interval: 1) do
        player.update_data
      end
    end
  end
end
