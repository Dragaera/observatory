module Observatory
  class ClassifyPlayerUpdateFrequency
    @queue = :classify_player_update_frequency

    def self.perform(player_id)
      player = Player[player_id]
      if player.nil?
        puts "No player with id #{ player_id.inspect }"
        return false
      end

      puts "Classifying update frequency of #{ player.inspect }"

      if player.player_data_points_dataset.count < 1
        puts "Not enough data to classify update frequency."
        return false
      end

      # We will compare it to #current_data.created_at, instead of Time.now.
      # This prevents the time difference from looking artifically big if the
      # classification job was delayed.
      # It does mean, however, that, if new player updates do not get
      # persisted, the player's classification will stay as-is.
      current_data = player.current_player_data_point
      # This might be the oldest point - which is always relevant.
      # It could also be #current_data, if that one changed.
      last_data_with_change = player.player_data_points_dataset.
        where(relevant: true).
        order(Sequel.desc(:created_at)).
        first

      time_to_change = current_data.created_at - last_data_with_change.created_at
      puts "Seconds since last change: #{ time_to_change }"

      # Find frequencies with big enough threshold, get lowest of them.
      f = UpdateFrequency.
        where(enabled: true).
        where { threshold >= time_to_change }.
        order(Sequel.asc(:threshold)).
        first

      unless f
        puts 'Player not active enough for any update frequency!'

        # Did not match any thresholds?
        f = UpdateFrequency.
          where(enabled: true, fallback: true).
          order(Sequel.asc(:threshold)).
          first

        if f
          puts "Assigning fallback frequency: '#{ f.name }'"
        else
          puts 'No fallback frequency found. Not changing anything.'
          return false
        end
      end

      puts "Classified as '#{ f.name }'"
      player.update_frequency = f
      player.next_update_at = current_data.created_at + f.interval
      player.save

      true
    end
  end
end
