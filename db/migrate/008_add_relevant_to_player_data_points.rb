Sequel.migration do
  up do
    alter_table :player_data_points do
      add_column :relevant, TrueClass, null: false, default: true
    end

    players = from(:players)
    players.each do |player_hsh|
      data_points = from(:player_data_points).where(player_id: player_hsh[:id]).order(Sequel.asc(:id))
      # Faster to set all to false, then selected ones to true, as most will be
      # non-relevant.
      data_points.update(relevant: false)
      prev = nil
      data_points.each do |hsh|
        if prev
          if hsh[:time_total] > prev[:time_total]
            data_points.where(id: hsh[:id]).update(relevant: true)
          end
        else
          # First data point
          data_points.where(id: hsh[:id]).update(relevant: true)
        end
        prev = hsh
      end
    end
  end

  down do
    alter_table :player_data_points do
      drop_column :relevant
    end
  end
end
