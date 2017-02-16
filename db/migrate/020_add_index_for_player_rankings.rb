Sequel.migration do
  up do
    alter_table :player_data_points do
      add_index [:id, Sequel.desc(:skill), :player_id]
      add_index [:id, Sequel.desc(:experience), :player_id]
      add_index [:id, Sequel.desc(:score), :player_id]
      add_index [:id, Sequel.desc(:score_per_second), :player_id]
    end
  end

  down do
    alter_table :player_data_points do
      drop_index [:id, Sequel.desc(:skill), :player_id]
      drop_index [:id, Sequel.desc(:experience), :player_id]
      drop_index [:id, Sequel.desc(:score), :player_id]
      drop_index [:id, Sequel.desc(:score_per_second), :player_id]
    end
  end
end
