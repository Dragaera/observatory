module Observatory
  class PlayerUpdate
    @queue = :get_player_data

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        puts "No player with id #{ player_id.inspect }"
        return false
      end

      if RateLimit.get_player_data?(type: :background)
        player.update_data
      else
        delay = rand(Observatory::Config::PlayerData::BACKOFF_DELAY)
        player.async_update_data(delay: delay)
        puts "Rescheduling player update for #{ player_id } in #{ delay }s."

        false
      end
    end
  end
end
