module Observatory
  class PlayerUpdate
    @queue = :get_player_data

    def self.perform(player_id)
      player = Player[player_id.to_i]
      if player.nil?
        puts "No player with id #{ player_id } (#{ player_id.to_i })"
        return false
      end

      player.update_data
    end
  end
end
