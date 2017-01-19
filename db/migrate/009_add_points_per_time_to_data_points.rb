Sequel.migration do
  up do
    alter_table :player_data_points do
      add_column :score_per_second,       Float, index: true
      add_column :score_per_second_field, Float, index: true
    end

    points = from(:player_data_points)
    points.
      exclude(time_total: [0, Sequel[:time_commander]]).
      update(
        score_per_second:       Sequel[:score].cast(:float) / Sequel[:time_total],
        score_per_second_field: Sequel[:score].cast(:float) / (Sequel[:time_total] - Sequel[:time_commander]),
    )

    points.
      where(time_total: [0, Sequel[:time_commander]]).
      update(
        score_per_second:       0,
        score_per_second_field: 0,
    )

    alter_table :player_data_points do
      set_column_not_null :score_per_second
      set_column_not_null :score_per_second_field
    end
  end

  down do
    alter_table :player_data_points do
      drop_column :score_per_second
      drop_column :score_per_second_field
    end
  end
end
