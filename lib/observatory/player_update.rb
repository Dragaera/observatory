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
        puts "Rescheduling player update for #{ player_id } in 10s."
        Resque.enqueue_in(
          10,
          PlayerUpdate,
          player_id
        )
      end
    end
  end
end
