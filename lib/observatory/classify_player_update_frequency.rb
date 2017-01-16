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

      if player.player_data.count < 2
        puts "Not enough data to classify update frequency."
        return false
      end

      current_data = player.current_player_data
      previous_data = nil
      # Look for the *newest* data entry which is different from the current
      # one.
      player.player_data_dataset.order(Sequel.desc(:created_at)).each do |data|
        if current_data.time_total > data.time_total
          previous_data = data
        end
      end

      # If all are equal, we'll pick the *oldest* for classification.
      unless previous_data
        puts 'All data points equal'
        previous_data = player.player_data_dataset.order(Sequel.asc(:created_at)).first
      end

      last_change = current_data.created_at - previous_data.created_at
      puts "Seconds since last change: #{ current_data.created_at } - #{ previous_data.created_at } = #{ last_change }"

      UpdateFrequency.where(enabled: true).order(Sequel.asc(:threshold)).each do |f|
        if last_change <= f.threshold
          puts "Classified as '#{ f.name }'"
          player.update_frequency = f
          player.save
          return true
        end
      end
      puts 'Player not active enough for any update frequency!'

      # Did not match any thresholds?
      fallback_frequency = UpdateFrequency.where(enabled: true, fallback: true).order(Sequel.asc(:threshold)).first
      if fallback_frequency
        puts "Assigning fallback frequency: '#{ f.name }'"
        player.update_frequency = fallback_frequency
        player.save
        return true
      else
        puts 'No fallback frequency found. Not changing anything.'
        return false
      end
    end
  end
end
