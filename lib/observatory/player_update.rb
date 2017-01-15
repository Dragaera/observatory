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
        delay = player.async_update_data(random_delay: true)
        puts "Rescheduling player update for #{ player_id } in #{ delay }s."

        false
      end
    end
  end
end
