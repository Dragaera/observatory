Sequel.migration do
  # Seems `foreign_key` does *not* create an index automatically!
  up do
    alter_table :players do
      add_index [:current_player_data_point_id]
      add_index [:update_frequency_id]
    end

    alter_table :player_data_points do
      add_index [:player_id]
    end

    alter_table :badges do
      add_index [:badge_group_id]
    end
  end

  down do
    alter_table :players do
      drop_index [:current_player_data_point_id]
      drop_index [:update_frequency_id]
    end

    alter_table :player_data_points do
      drop_index [:player_id]
    end

    alter_table :badges do
      drop_index [:badge_group_id]
    end
  end
end
