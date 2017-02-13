Sequel.migration do
  up do
    alter_table :players do
      # Old-style key name
      drop_foreign_key [:current_player_data_point_id], name: :players_current_player_data_id_fkey
    end

    from(:player_data_points).
      where(relevant: false).
      exclude(
        id: from(:players).
        select(:current_player_data_point_id)
    ).
    delete()

    alter_table :players do
      add_foreign_key [:current_player_data_point_id], :player_data_points
    end
  end

  down do
    # No way to restore data points. ;)
    alter_table :players do
      drop_foreign_key [:current_player_data_point_id]
      # Old-style key name
      add_foreign_key [:current_player_data_point_id], :player_data_points, name: :players_current_player_data_id_fkey
    end
  end
end
