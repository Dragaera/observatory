Sequel.migration do
  up do
    rename_table(:player_data, :player_data_points)

    alter_table :players do
      rename_column :current_player_data_id, :current_player_data_point_id
    end
  end

  down do
    rename_table(:player_data_points, :player_data)

    alter_table :players do
      rename_column :current_player_data_point_id, :current_player_data_id
    end
  end
end
