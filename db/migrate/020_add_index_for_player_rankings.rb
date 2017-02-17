Sequel.migration do
  up do
    alter_table :player_data_points do
      add_index [
        :id,
        Sequel.desc(:skill),
        Sequel.desc(:experience),
        Sequel.desc(:score),
        Sequel.desc(:score_per_second),
        :player_id
      ]
    end
  end

  down do
    alter_table :player_data_points do
      drop_index [
        :id,
        Sequel.desc(:skill),
        Sequel.desc(:experience),
        Sequel.desc(:score),
        Sequel.desc(:score_per_second),
        :player_id
      ]
    end
  end
end
