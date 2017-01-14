module Observatory
  class PlayerUpdate
    @queue = :get_player_data

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        puts "No player with id #{ player_id } (#{ player_id.to_i })"
        return false
      end

      if RateLimit.get_player_data?(type: :background)
        player.update_data
      else
        delay = 10 + rand(5) + 1
        puts "Rescheduling player update for #{ player_id } in #{ delay }s."
        Resque.enqueue_in(
          delay,
          PlayerUpdate,
          player_id
        )
      end
    end
  end
end
